import os
import warnings
import psycopg2
import pandas as pd
from dotenv import load_dotenv
from openai import OpenAI

# 隱藏 pandas 連線警告，保持 Terminal 乾淨
warnings.filterwarnings("ignore", category=UserWarning)

# Load environment variables
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "..", ".env"))

# 1. Initialize OpenAI Client for OpenRouter
api_key = os.environ.get("OPENROUTER_API_KEY")
client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=api_key,
)

# 2. Establish connection to PostgreSQL
db_connection = psycopg2.connect(
    host="localhost",
    port="5432",
    database="olist_ecommerce",
    user="postgres",
    password=os.environ.get("PG_PASSWORD")
)


def get_db_schema_context(schema_name="core"):
    """
    【動態抓取架構】從 PostgreSQL 的 information_schema 自動撈出所有表名與欄位名，
    並自動動態組裝成 LLM 的 System Prompt。
    """
    query = """
            SELECT table_name, column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = %s
            ORDER BY table_name, ordinal_position; \
            """
    cursor = db_connection.cursor()
    cursor.execute(query, (schema_name,))
    rows = cursor.fetchall()
    cursor.close()

    # 將撈出來的元數據動態組裝成文字結構
    schema_dict = {}
    for table, col, dtype in rows:
        if table not in schema_dict:
            schema_dict[table] = []
        schema_dict[table].append(f"  - {col} ({dtype})")

    schema_text = ""
    for table, cols in schema_dict.items():
        schema_text += f"Table: {schema_name}.{table}\n"
        schema_text += "\n".join(cols) + "\n\n"

    # 組裝成最終的 System Prompt Context
    base_context = f"""You are an expert SQL Assistant for an e-commerce platform. 
Given a user question, your job is to output a syntactically correct PostgreSQL query.
You have access to the following relational database schema under the '{schema_name}' schema:

{schema_text}
Critical Requirements:
- Return ONLY valid, executable PostgreSQL code.
- Do NOT wrap code in markdown formatting unless using standard ```sql ``` blocks.
- Do NOT provide conversational explanations. Just return the raw code block.
- Always prefix tables with the '{schema_name}.' schema name.
- If calculation of total consumption/sales is needed, SUM the (price + freight_value) columns found in the fact tables if a single payment column is missing.
"""
    return base_context


def execute_natural_language_query(user_prompt: str) -> pd.DataFrame:
    """
    透過動態產生的 Schema 上下文，將自然語言轉為 SQL 並執行。
    """
    print(f"[INPUT] User Prompt: {user_prompt}")

    # 這裡就是最 Smart 的地方：每次執行都抓取最新、最真實的資料庫架構
    dynamic_schema = get_db_schema_context(schema_name="core")

    completion = client.chat.completions.create(
        extra_headers={
            "HTTP-Referer": "https://github.com/",
            "X-Title": "Olist SQL Portfolio",
        },
        model="openrouter/auto",
        messages=[
            {"role": "system", "content": dynamic_schema},
            {"role": "user", "content": f"Translate this request to PostgreSQL: {user_prompt}"}
        ],
        temperature=0.0,
    )

    raw_response = completion.choices[0].message.content
    try:
        extracted_sql = raw_response.split("```sql")[1].split("```")[0].strip()
    except IndexError:
        extracted_sql = raw_response.strip()

    print(f"[GENERATED SQL]\n{extracted_sql}\n")

    try:
        query_result_df = pd.read_sql_query(extracted_sql, db_connection)
        return query_result_df
    except Exception as query_error:
        print(f"[ERROR] SQL Execution failed: {str(query_error)}")
        return pd.DataFrame()


# --- Execution Runtime ---
if __name__ == "__main__":
    sample_request = "幫我搵出總消費金額最高嘅前 5 個 customer_city"
    result_dataframe = execute_natural_language_query(sample_request)

    print("--- [RESULTS LAYER] ---")
    print(result_dataframe)