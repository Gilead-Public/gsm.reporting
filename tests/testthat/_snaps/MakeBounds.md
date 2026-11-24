# MakeBounds makes dfBounds (#41, #42)

    Code
      MakeBounds(dfResults = dplyr::filter(gsm.core::reportingResults, SnapshotDate ==
        "2025-04-01"), dfMetrics = gsm.core::reportingMetrics)
    Message
      Creating stacked dfBounds data for strMetrics
      Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
      nStep was not provided. Setting default step to 3.116.
      Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
      nStep was not provided. Setting default step to 3.116.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 3.116.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 3.116.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 16.992.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.064.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.064.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.056.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 32.768.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 2.048.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 8.192.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 32.768.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 0.08.
      Parsed 0.9,0.85 to numeric vector: 0.9, 0.85
      Parsed 1.5,2.5 to numeric vector: 1.5, 2.5
      Parsed 1,2 to numeric vector: 1, 2
      Parsed 1,2 to numeric vector: 1, 2
      Parsed 0.2,0.3 to numeric vector: 0.2, 0.3
      Parsed 0.2,0.3 to numeric vector: 0.2, 0.3
      Parsed 0.2,0.3 to numeric vector: 0.2, 0.3
      Parsed 0.2,0.3 to numeric vector: 0.2, 0.3
      Parsed 0.2,0.3 to numeric vector: 0.2, 0.3
      Parsed 0.2,0.3 to numeric vector: 0.2, 0.3
    Condition
      Warning:
      Warning: Failed to parse strThreshold ('NA') to a numeric vector.
    Output
      # A tibble: 11,253 x 8
         Threshold Denominator LogDenominator Numerator  Metric MetricID       StudyID
             <dbl>       <dbl>          <dbl>     <dbl>   <dbl> <chr>          <chr>  
       1        -2        107.           4.67     0.120 0.00112 Analysis_kri0~ AA-AA-~
       2        -2        110.           4.70     0.249 0.00226 Analysis_kri0~ AA-AA-~
       3        -2        113.           4.73     0.380 0.00336 Analysis_kri0~ AA-AA-~
       4        -2        116.           4.76     0.513 0.00441 Analysis_kri0~ AA-AA-~
       5        -2        119.           4.78     0.648 0.00543 Analysis_kri0~ AA-AA-~
       6        -2        123.           4.81     0.784 0.00640 Analysis_kri0~ AA-AA-~
       7        -2        126.           4.83     0.922 0.00734 Analysis_kri0~ AA-AA-~
       8        -2        129.           4.86     1.06  0.00824 Analysis_kri0~ AA-AA-~
       9        -2        132.           4.88     1.20  0.00911 Analysis_kri0~ AA-AA-~
      10        -2        135.           4.91     1.34  0.00995 Analysis_kri0~ AA-AA-~
      # i 11,243 more rows
      # i 1 more variable: SnapshotDate <date>

# MakeBounds uses user-supplied strMetrics (#41)

    Code
      MakeBounds(dfResults = dplyr::filter(gsm.core::reportingResults, SnapshotDate ==
        "2025-04-01"), dfMetrics = gsm.core::reportingMetrics, strMetrics = "Analysis_kri0001")
    Message
      Creating stacked dfBounds data for strMetrics
      Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
      nStep was not provided. Setting default step to 3.116.
    Output
      # A tibble: 1,217 x 8
         Threshold Denominator LogDenominator Numerator  Metric MetricID       StudyID
             <dbl>       <dbl>          <dbl>     <dbl>   <dbl> <chr>          <chr>  
       1        -2        107.           4.67     0.120 0.00112 Analysis_kri0~ AA-AA-~
       2        -2        110.           4.70     0.249 0.00226 Analysis_kri0~ AA-AA-~
       3        -2        113.           4.73     0.380 0.00336 Analysis_kri0~ AA-AA-~
       4        -2        116.           4.76     0.513 0.00441 Analysis_kri0~ AA-AA-~
       5        -2        119.           4.78     0.648 0.00543 Analysis_kri0~ AA-AA-~
       6        -2        123.           4.81     0.784 0.00640 Analysis_kri0~ AA-AA-~
       7        -2        126.           4.83     0.922 0.00734 Analysis_kri0~ AA-AA-~
       8        -2        129.           4.86     1.06  0.00824 Analysis_kri0~ AA-AA-~
       9        -2        132.           4.88     1.20  0.00911 Analysis_kri0~ AA-AA-~
      10        -2        135.           4.91     1.34  0.00995 Analysis_kri0~ AA-AA-~
      # i 1,207 more rows
      # i 1 more variable: SnapshotDate <date>

# MakeBounds makes poisson dfBounds (#41)

    Code
      MakeBounds(dfResults = dplyr::filter(gsm.core::reportingResults, SnapshotDate ==
        "2025-04-01"), dfMetrics = reportingMetrics)
    Message
      Creating stacked dfBounds data for strMetrics
      Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
      nStep was not provided. Setting default step to 3.116.
      Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
      nStep was not provided. Setting default step to 3.116.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 3.116.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 3.116.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 16.992.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.064.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.064.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.056.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 32.768.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 2.048.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 8.192.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 32.768.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 0.08.
      Parsed 0.9,0.85 to numeric vector: 0.9, 0.85
      Parsed 1.5,2.5 to numeric vector: 1.5, 2.5
      Parsed 1,2 to numeric vector: 1, 2
      Parsed 1,2 to numeric vector: 1, 2
      Parsed 0.2,0.3 to numeric vector: 0.2, 0.3
      Parsed 0.2,0.3 to numeric vector: 0.2, 0.3
      Parsed 0.2,0.3 to numeric vector: 0.2, 0.3
      Parsed 0.2,0.3 to numeric vector: 0.2, 0.3
      Parsed 0.2,0.3 to numeric vector: 0.2, 0.3
      Parsed 0.2,0.3 to numeric vector: 0.2, 0.3
    Condition
      Warning:
      Warning: Failed to parse strThreshold ('NA') to a numeric vector.
    Output
      # A tibble: 11,253 x 8
         Threshold Denominator LogDenominator Numerator  Metric MetricID       StudyID
             <dbl>       <dbl>          <dbl>     <dbl>   <dbl> <chr>          <chr>  
       1        -2        107.           4.67     0.120 0.00112 Analysis_kri0~ AA-AA-~
       2        -2        110.           4.70     0.249 0.00226 Analysis_kri0~ AA-AA-~
       3        -2        113.           4.73     0.380 0.00336 Analysis_kri0~ AA-AA-~
       4        -2        116.           4.76     0.513 0.00441 Analysis_kri0~ AA-AA-~
       5        -2        119.           4.78     0.648 0.00543 Analysis_kri0~ AA-AA-~
       6        -2        123.           4.81     0.784 0.00640 Analysis_kri0~ AA-AA-~
       7        -2        126.           4.83     0.922 0.00734 Analysis_kri0~ AA-AA-~
       8        -2        129.           4.86     1.06  0.00824 Analysis_kri0~ AA-AA-~
       9        -2        132.           4.88     1.20  0.00911 Analysis_kri0~ AA-AA-~
      10        -2        135.           4.91     1.34  0.00995 Analysis_kri0~ AA-AA-~
      # i 11,243 more rows
      # i 1 more variable: SnapshotDate <date>

