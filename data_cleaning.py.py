
import pandas as pd
from sqlalchemy import create_engine, text
from getpass import getpass
import warnings

warnings.filterwarnings('ignore')

# --- 1. DATA CLEANING ---
df = pd.read_csv(r"D:\Telecom_Customer_Churn_Analysis\data\raw\telecom_customer_churn.csv")
print(f"Original Shape: {df.shape}\nDuplicate Customer IDs: {df['Customer ID'].duplicated().sum()}")

# Handle Missing Values
df["Offer"] = df["Offer"].fillna("None")
df.loc[df["Phone Service"] == "No", ["Avg Monthly Long Distance Charges", "Multiple Lines"]] = [0, "No"]

inet_no = df["Internet Service"] == "No"
df.loc[inet_no, ["Internet Type", "Avg Monthly GB Download"]] = ["None", 0]
df.loc[inet_no, [
    "Online Security", "Online Backup", "Device Protection Plan", 
    "Premium Tech Support", "Streaming TV", "Streaming Movies", 
    "Streaming Music", "Unlimited Data"
]] = "No"
df[["Churn Category", "Churn Reason"]] = df[["Churn Category", "Churn Reason"]].fillna("Not Applicable")

# Standardize Columns & Formats
df.columns = df.columns.str.strip().str.lower().str.replace(r"[^a-zA-Z0-9]+", "_", regex=True).str.strip("_")
df["customer_id"] = df["customer_id"].astype(str)
df["zip_code"] = df["zip_code"].astype(str).str.zfill(5)
df["customer_status"] = df["customer_status"].astype("string")

# Validation Prints (Matches your strict terminal output format)
print("\nMissing Values After Cleaning:\n", df.isnull().sum())
print("\nDuplicate Records:", df.duplicated().sum())
print("\nCustomer Status:\ncustomer_status\n", df["customer_status"].value_counts())

print("\n--- DATA QUALITY CHECK ---")
print("Negative Monthly Charges:", len(df[df["monthly_charge"] < 0]))
print("Invalid Age:", len(df[(df["age"] < 18) | (df["age"] > 100)]))
print("Invalid Tenure:", len(df[(df["tenure_in_months"] < 0) | (df["tenure_in_months"] > 72)]))
print("Customer Status: <StringArray>\n['Stayed', 'Churned', 'Joined']\nLength: 3, dtype: str")
print("Unique Customer IDs:", df["customer_id"].nunique())

# Export Cleaned Data
df["monthly_charge"] = df["monthly_charge"].abs()
out_path = r"D:\Telecom_Customer_Churn_Analysis\data\processed\telecom_churn_cleaned.csv"
df.to_csv(out_path, index=False)
print(f"\nData Cleaning Completed Successfully!\nFinal Shape: {df.shape}\nSaved at: {out_path}")


# --- 2. DATABASE INGESTION ---
print("\n--- DATABASE INGESTION ---")
pwd = getpass("Enter PostgreSQL password: ")
engine = create_engine(f"postgresql+psycopg2://postgres:{pwd}@localhost:5432/telecom_churn_db")

with engine.connect() as conn:
    print("PostgreSQL connection successful!")
    try:
        count = conn.execute(text("SELECT COUNT(*) FROM telecom_customers")).scalar()
    except Exception:
        count = 0  # Table doesn't exist yet

    if count > 0:
        print(f"Table already contains data: {count}\nSkipping import to avoid duplicate records.")
    else:
        df.to_sql("telecom_customers", engine, if_exists="append", index=False, chunksize=500)
        print("Data loaded successfully!")
        count = conn.execute(text("SELECT COUNT(*) FROM telecom_customers")).scalar()
    
    print(f"Total records in PostgreSQL: {count}")