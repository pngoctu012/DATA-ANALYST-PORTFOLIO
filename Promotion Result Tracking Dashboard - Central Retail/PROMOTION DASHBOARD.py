# sales ------------------------------------------------------------------------------------
import glob
import os
from io import StringIO
import pandas as pd
import psycopg2
from sqlalchemy import create_engine, text
engine = create_engine("postgresql+psycopg2://postgres:Pnt%4012092003@localhost:5432/CRV - FRESH")

files = glob.glob("W*.csv")

conn = psycopg2.connect(
    host="localhost",
    database="CRV - FRESH",
    user="postgres",
    password="Pnt@12092003"
)

cur = conn.cursor()

for file in files:

    file_name = os.path.basename(file)

    # Kiểm tra file đã import chưa
    cur.execute("""
        SELECT EXISTS (
            SELECT 1
            FROM bronze_sales
            WHERE source_file = %s
        )
    """, (file_name,))

    loaded = cur.fetchone()[0]

    if loaded:
        print(f"Skip: {file_name}")
        continue

    print(f"Loading: {file_name}")

    df = pd.read_csv(file, encoding="cp1252")
    df["source_file"] = file_name
    df['Article Code'] = df['Article Code'].astype(str).str.zfill(8)
    df['Quantity'] = df['Quantity'].str.replace(",","",regex=False).fillna(0).astype(int)
    df['Turnover'] = df['Turnover'].str.replace(",","",regex=False).fillna(0).astype(int)
    df['Vat'] = df['Vat'].str.replace(",","",regex=False).fillna(0).astype(int)
    df['Cost Value'] = df['Cost Value'].str.replace(",","",regex=False).fillna(0).astype(int)
    df['Margin_Value'] = df['Margin_Value'].str.replace(",","",regex=False).fillna(0).astype(int)


    buffer = StringIO()
    df.to_csv(buffer, index=False)
    buffer.seek(0)

    cur.copy_expert("""
        COPY bronze_sales
        FROM STDIN
        WITH (
            FORMAT CSV,
            HEADER TRUE
        )
    """, buffer)

        ## silver_sales -----------------

    try:
        silver_sales = (
            df.groupby(
                ["Store", "Sale Date", "WeekNumber", "Article Code"],
                as_index=False
            )
            .agg(
                quantity=("Quantity", "sum"),
                turnover=("Turnover", "sum"),
                vat=("Vat", "sum"),
                cost_value=("Cost Value", "sum"),
                margin_value=("Margin_Value", "sum")
            )
        )

        buffer = StringIO()
        silver_sales.to_csv(buffer, index=False)
        buffer.seek(0)

        cur.copy_expert("""
            COPY temp_silver_sales
            FROM STDIN
            WITH (FORMAT CSV, HEADER TRUE)
        """, buffer)

        cur.execute("""
            INSERT INTO silver_sales
            SELECT *
            FROM temp_silver_sales
            ON CONFLICT (store, sale_date, article_code)
            DO NOTHING;
        """)

        cur.execute("TRUNCATE temp_silver_sales")

        print(f"Silver SUCCESS: {file_name}")

    except Exception as e:
        conn.rollback()
        print(f"Silver FAILED: {file_name} - {e}")

conn.commit()   # commit sau mỗi file
cur.close()
conn.close()

# region ------------------------------------------------------------------------------------
region = pd.read_csv('DIM_TABLE/Region.csv', encoding="cp1252")

with engine.begin() as conn:
    conn.execute(text("TRUNCATE TABLE bronze_region"))

region.columns = [
    "store",
    "store_code",
    "store_name",
    "bu_format",
    "region_7",
    "region_5",
    "region_3"
]
region.to_sql("bronze_region", engine, if_exists="append", index=False)

# weekend ------------------------------------------------------------------------------------
weekend = pd.read_csv('DIM_TABLE/Weekend.csv', encoding="cp1252")
weekend['Goldcode'] = weekend['Goldcode'].astype(str).str.zfill(8)
weekend.columns = [
    "campaign",
    "goldcode",
    "region",
    "begin",
    "end"
]
with engine.begin() as conn:
    conn.execute(text("TRUNCATE TABLE bronze_weekend"))
weekend.to_sql("bronze_weekend", engine, if_exists="append", index=False)

# catalog ------------------------------------------------------------------------------------
catalog = pd.read_csv('DIM_TABLE/Catalog.csv', encoding="cp1252")
catalog['Goldcode'] = catalog['Goldcode'].astype(str).str.zfill(8)
catalog.columns = [
    "campaign",
    "goldcode",
    "region",
    "begin",
    "end",
    "last_year"
]
with engine.begin() as conn:
    conn.execute(text("TRUNCATE TABLE bronze_catalog"))
catalog.to_sql("bronze_catalog", engine, if_exists="append", index=False)

# fair ------------------------------------------------------------------------------------
fair = pd.read_csv('DIM_TABLE/Fair.csv', encoding="cp1252")
fair['Goldcode'] = fair['Goldcode'].astype(str).str.zfill(8)
fair.columns = [
    "campaign",
    "goldcode",
    "region",
    "level",
    "begin",
    "end"
]
with engine.begin() as conn:
    conn.execute(text("TRUNCATE TABLE bronze_fair"))
fair.to_sql("bronze_fair", engine, if_exists="append", index=False)

# others ------------------------------------------------------------------------------------
others = pd.read_csv('DIM_TABLE/Others.csv', encoding='cp1252', dtype={'Goldcode': str, 'Region': str})
others['Goldcode'] = others['Goldcode'].str.zfill(8)
others.columns = [
    "campaign",
    "goldcode",
    "region",
    "level",
    "begin",
    "end"
]
with engine.begin() as conn:
    conn.execute(text("TRUNCATE TABLE bronze_others"))
others.to_sql("bronze_others", engine, if_exists="append", index=False)

others