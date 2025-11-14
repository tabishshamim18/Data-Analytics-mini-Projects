# 🍿 Netflix Viewership Breakdown by Content Type & Language — Exploratory Data Analysis

## 📝 Executive Summary
Netflix is one of the largest global streaming platforms, offering a vast library of TV shows and movies in multiple languages. To stay competitive, it's important to understand **which types of content attract the most viewership** and **which languages dominate audience attention**.

This project performs a focused **exploratory data analysis (EDA)** on a Netflix dataset to:
- 🧹 Clean and prepare the data for analysis  
- 📊 Explore **total viewership hours by content type** (Movies vs TV Shows)  
- 🌐 Analyze **viewership distribution by language**  
- 📈 Visualize insights using **interactive Plotly bar charts**

By looking at **viewership hours**, we can identify content patterns that are critical for **content strategy, language localization**, and **market expansion decisions**.

---

## 💼 Business Problem
Netflix operates in over 190 countries and offers content in multiple languages and formats. However, without proper analysis of its content performance, it's difficult to answer key strategic questions like:
- Which type of content (Movies or TV Shows) drives **higher total viewership**?  
- Which **languages** account for the largest share of viewing hours?  
- How can Netflix use these insights to **optimize its content investments**?

Understanding these patterns can help guide:
- 📺 **Content format strategy** — balancing Movies and TV Shows effectively  
- 🌍 **Language localization** — focusing on languages with high engagement  
- 📈 **Catalog growth** — identifying opportunities to expand in underrepresented segments

---

## 🧭 Methodology

The analysis was conducted step by step in a **Jupyter Notebook** using **Python** and **Plotly**:

### 1. **Data Loading**
- Imported the dataset `netflix_content.csv` using **Pandas**.  
- Displayed the first few rows to understand the structure and inspected data types.

### 2. **Data Cleaning**
- Cleaned the `Hours Viewed` column by removing commas and converting it from string to **float** for numeric analysis.  
- Converted the `Release Date` column to **datetime** format for future time-based analysis (though not used in aggregations here).  
- Rechecked data types to ensure consistency.

### 3. **Exploratory Data Analysis**

#### a) **Viewership by Content Type**
- Grouped the data by `Content Type` (Movies vs TV Shows).  
- Calculated the total `Hours Viewed` for each category.  
- Visualized the results using a **Plotly bar chart** titled:
  > “Total Viewership Hours by Content Type”  
- The visualization clearly shows which content type contributes more to Netflix’s overall viewing hours.

#### b) **Viewership by Language**
- Grouped the data by `Language Indicator`.  
- Calculated the total `Hours Viewed` for each language.  
- Sorted the results in descending order to identify the top-performing languages.  
- Displayed the aggregated data to highlight language distribution patterns.

### 4. **Visualization**
- Used **Plotly** for clean, interactive bar charts, making the results easier to interpret and visually appealing.  
- Adjusted chart titles, axes labels, colors, and layout for clarity.

---

## 🧠 Skills Demonstrated

| Skill Area              | Techniques Used |
|--------------------------|-----------------|
| **Python**               | Data loading, manipulation with Pandas |
| **Data Cleaning**        | String replacement, type conversion, datetime formatting |
| **Exploratory Data Analysis** | Grouping, aggregation, sorting |
| **Data Visualization**   | Plotly bar, scatter and line charts, figure customization |
| **Analytical Thinking**  | Identifying key metrics (Hours Viewed) to derive content insights |

---

## 📈 Results & Insights

### 1️⃣ **Content Type Viewership**
- Total viewing hours were aggregated by **Movies** and **TV Shows**.  
- The bar chart visualization clearly shows **TV Shows** dominates the viewership.  
- This provides a data-backed understanding of **audience format preferences**, which can help in balancing production and acquisition strategies.

### 2️⃣ **Language Viewership**
- Total viewing hours were aggregated by **Language**.  
- Sorting the results revealed that **English** contributed the majority of viewership followed by **Korean**.  
- This insight is valuable for:
  - Prioritizing **subtitling/dubbing efforts**  
  - Guiding **localized content creation**  
  - Identifying **underperforming languages** for potential growth opportunities

---

## 🚀 Next Steps
While this project focuses on **content type and language**, future enhancements could include:
- 📅 **Time-based trend analysis** using the cleaned `Release Date` column to explore viewership patterns over time.  
- 🧠 **Genre-level analysis** to understand which genres are most watched.  
- 🌍 **Country or region breakdown** for deeper market insights.  
- 📊 Integrating **viewership data over time** to identify seasonal trends.

---

## 🧰 Tech Stack
- **Language:** Python  
- **Libraries:** Pandas, Plotly  
- **Environment:** Jupyter Notebook  
- **Dataset:** Netflix Content Dataset (CSV)

---

## 📌 Repository Structure

📁 Netflix-Content-Strategy-Analysis/
├── Netflix Content Strategy Analysis.ipynb # Analysis & visualization notebook
├── netflix_content.csv # Dataset used in the project
└── README.md

---

## 👤 Author
**Tabish Shamim**  
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/tabish-shamim-2818h)  
[![Email](https://img.shields.io/badge/Email-Contact-red?style=flat-square&logo=gmail)](mailto:tabishshamim94@gmail.com)

---

⭐ If you found this project insightful, consider **starring the repository** — it supports more analytics work like this.


