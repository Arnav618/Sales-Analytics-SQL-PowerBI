# DAX Measures

This dashboard uses DAX for KPI calculations, time intelligence, ranking analysis, and dynamic business insights.

---

## Profit Margin

**Purpose:** Calculates overall profitability while safely handling divide-by-zero scenarios.

```DAX
Profit Margin =
DIVIDE(
    [Total Profit],
    [Total Sales],
    0
)
```

---

## Average Order Value

**Purpose:** Measures average revenue generated per order.

```DAX
Average Order Value =
DIVIDE(
    [Total Sales],
    [Total Orders]
)
```

---

## Previous Month Sales

**Purpose:** Supports month-over-month sales comparison.

```DAX
Previous Month Sales =
CALCULATE(
    [Total Sales],
    DATEADD(
        'Date'[Date],
        -1,
        MONTH
    )
)
```

---

## Top Region by Sales

**Purpose:** Dynamically identifies the highest-performing region based on current report filters.

**Concepts Used:** VAR, ADDCOLUMNS, SUMMARIZE, TOPN, MAXX

```DAX
Top Region by Sales =

VAR SummaryTable =
    ADDCOLUMNS(
        SUMMARIZE(
            ALLSELECTED(Orders[region]),
            Orders[region]
        ),
        "TotalSales",
        CALCULATE(
            SUM(Sales[Sales])
        )
    )

VAR TopRegion =
    TOPN(
        1,
        SummaryTable,
        [TotalSales],
        DESC
    )

RETURN
    MAXX(
        TopRegion,
        Orders[region]
    )
```

---

## Worst Subcategories

**Purpose:** Identifies the lowest-profit subcategories currently visible in the report.

**Concepts Used:** TOPN, FILTER, CONCATENATEX

```DAX
Worst Subcategories =

CONCATENATEX(
    TOPN(
        2,
        FILTER(
            VALUES(Products[Sub Catgory]),
            [Total Profit] < 0
        ),
        [Total Profit],
        ASC
    ),
    Products[Sub Catgory],
    " and "
)
```

---

## Dynamic Insight

**Purpose:** Generates automated business commentary based on category selection and current filter context.

**Concepts Used:** VAR, FILTER, ADDCOLUMNS, CONCATENATEX, COUNTROWS, TOPN, MAXX, FORMAT, IF

```DAX
Dynamic Insight =

VAR Cat =
    SELECTEDVALUE(
        Products[Category],
        "Selected Category"
    )

VAR NegativeTable =
    FILTER(
        ADDCOLUMNS(
            VALUES(Products[Sub Catgory]),
            "ProfitValue",
            [Total Profit]
        ),
        [ProfitValue] < 0
    )

VAR NegativeSubcats =
    CONCATENATEX(
        NegativeTable,
        Products[Sub Catgory],
        " and "
    )

VAR NegativeCount =
    COUNTROWS(
        NegativeTable
    )

RETURN
IF(
    NegativeCount > 0,
    Cat &
    " profitability is primarily impacted by " &
    NegativeSubcats,
    Cat &
    " has no loss-making subcategories."
)
```

---

## DAX Concepts Demonstrated

* CALCULATE
* DATEADD
* VAR
* TOPN
* FILTER
* ADDCOLUMNS
* SUMMARIZE
* CONCATENATEX
* MAXX
* DIVIDE
* Dynamic Text Generation
* Time Intelligence
