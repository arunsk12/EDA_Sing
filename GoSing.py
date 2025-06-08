import pandas as pd
import matplotlib.pyplot as plt
import plotly.express as px
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, sum, greatest, pow

# Start Spark session
spark = SparkSession.builder.appName("Singapore_Investment_Analysis").getOrCreate()

# Load the dataset into a Spark DataFrame
df = spark.read.csv("GoSing.csv", header=True, inferSchema=True)

# Select the relevant columns and cast them to float
investment_columns = df.columns[1:]  # Exclude 'Business'
df = df.select("Business", *[col(c).cast("float") for c in investment_columns])

# Function to convert RDD to Pandas DataFrame
def rdd_to_pandas(rdd, column_names):
    return pd.DataFrame(rdd.collect(), columns=column_names)

# 1. Top 5 Businesses by Average Investment
avg_investment_df = df.withColumn(
    "average_investment", 
    sum([col(c) for c in investment_columns]) / len(investment_columns)
)
avg_investment_df = avg_investment_df.orderBy(col("average_investment").desc())

# Convert to RDD and then to Pandas DataFrame
avg_investment_rdd = avg_investment_df.rdd.persist()
avg_investment_pd = rdd_to_pandas(avg_investment_rdd, ["Business", "average_investment"])

# Plotting using Matplotlib
plt.figure(figsize=(10, 6))
plt.bar(avg_investment_pd["Business"], avg_investment_pd["average_investment"], color='skyblue')
plt.title("Top 5 Businesses by Average Investment")
plt.xlabel("Business")
plt.ylabel("Average Investment")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# Plotting using Plotly for interactivity
fig = px.bar(avg_investment_pd.head(5), x='Business', y='average_investment', 
             title="Top 5 Businesses by Average Investment")
fig.show()
