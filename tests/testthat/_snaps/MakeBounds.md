# MakeBounds makes dfBounds (#41, #42)

    Code
      MakeBounds(dfResults = dplyr::filter(gsm.core::reportingResults, SnapshotDate ==
        "2025-04-01"), dfMetrics = gsm.core::reportingMetrics)
    Message
      Creating stacked dfBounds data for strMetrics
      Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
      nStep was not provided. Setting default step to 2.82.
      Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
      nStep was not provided. Setting default step to 2.82.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 2.82.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 2.82.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 15.812.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.056.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.056.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 28.672.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 1.792.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 7.168.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 28.672.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 0.068.
      Parsed 0.9,0.85 to numeric vector: 0.9, 0.85
      Parsed 1.5,2.5 to numeric vector: 1.5, 2.5
      Parsed 1,2 to numeric vector: 1, 2
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.056.
    Condition
      Warning:
      Warning: Failed to parse strThreshold ('NA') to a numeric vector.
    Output
      # A tibble: 11,497 x 8
         Threshold Denominator LogDenominator Numerator  Metric MetricID       StudyID
             <dbl>       <dbl>          <dbl>     <dbl>   <dbl> <chr>          <chr>  
       1        -2        77.3           4.35    0.0790 0.00102 Analysis_kri0~ AA-AA-~
       2        -2        80.1           4.38    0.202  0.00252 Analysis_kri0~ AA-AA-~
       3        -2        83.0           4.42    0.326  0.00393 Analysis_kri0~ AA-AA-~
       4        -2        85.8           4.45    0.453  0.00528 Analysis_kri0~ AA-AA-~
       5        -2        88.6           4.48    0.581  0.00656 Analysis_kri0~ AA-AA-~
       6        -2        91.4           4.52    0.711  0.00778 Analysis_kri0~ AA-AA-~
       7        -2        94.2           4.55    0.843  0.00895 Analysis_kri0~ AA-AA-~
       8        -2        97.1           4.58    0.977  0.0101  Analysis_kri0~ AA-AA-~
       9        -2        99.9           4.60    1.11   0.0111  Analysis_kri0~ AA-AA-~
      10        -2       103.            4.63    1.25   0.0122  Analysis_kri0~ AA-AA-~
      # i 11,487 more rows
      # i 1 more variable: SnapshotDate <date>

# MakeBounds uses user-supplied strMetrics (#41)

    Code
      MakeBounds(dfResults = dplyr::filter(gsm.core::reportingResults, SnapshotDate ==
        "2025-04-01"), dfMetrics = gsm.core::reportingMetrics, strMetrics = "Analysis_kri0001")
    Message
      Creating stacked dfBounds data for strMetrics
      Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
      nStep was not provided. Setting default step to 2.82.
    Output
      # A tibble: 1,231 x 8
         Threshold Denominator LogDenominator Numerator  Metric MetricID       StudyID
             <dbl>       <dbl>          <dbl>     <dbl>   <dbl> <chr>          <chr>  
       1        -2        77.3           4.35    0.0790 0.00102 Analysis_kri0~ AA-AA-~
       2        -2        80.1           4.38    0.202  0.00252 Analysis_kri0~ AA-AA-~
       3        -2        83.0           4.42    0.326  0.00393 Analysis_kri0~ AA-AA-~
       4        -2        85.8           4.45    0.453  0.00528 Analysis_kri0~ AA-AA-~
       5        -2        88.6           4.48    0.581  0.00656 Analysis_kri0~ AA-AA-~
       6        -2        91.4           4.52    0.711  0.00778 Analysis_kri0~ AA-AA-~
       7        -2        94.2           4.55    0.843  0.00895 Analysis_kri0~ AA-AA-~
       8        -2        97.1           4.58    0.977  0.0101  Analysis_kri0~ AA-AA-~
       9        -2        99.9           4.60    1.11   0.0111  Analysis_kri0~ AA-AA-~
      10        -2       103.            4.63    1.25   0.0122  Analysis_kri0~ AA-AA-~
      # i 1,221 more rows
      # i 1 more variable: SnapshotDate <date>

# MakeBounds makes poisson dfBounds (#41)

    Code
      MakeBounds(dfResults = dplyr::filter(gsm.core::reportingResults, SnapshotDate ==
        "2025-04-01"), dfMetrics = reportingMetrics)
    Message
      Creating stacked dfBounds data for strMetrics
      Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
      nStep was not provided. Setting default step to 2.82.
      Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
      nStep was not provided. Setting default step to 2.82.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 2.82.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 2.82.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 15.812.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.056.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.056.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 28.672.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 1.792.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 7.168.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 28.672.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 0.068.
      Parsed 0.9,0.85 to numeric vector: 0.9, 0.85
      Parsed 1.5,2.5 to numeric vector: 1.5, 2.5
      Parsed 1,2 to numeric vector: 1, 2
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.056.
    Condition
      Warning:
      Warning: Failed to parse strThreshold ('NA') to a numeric vector.
    Output
      # A tibble: 11,497 x 8
         Threshold Denominator LogDenominator Numerator  Metric MetricID       StudyID
             <dbl>       <dbl>          <dbl>     <dbl>   <dbl> <chr>          <chr>  
       1        -2        77.3           4.35    0.0790 0.00102 Analysis_kri0~ AA-AA-~
       2        -2        80.1           4.38    0.202  0.00252 Analysis_kri0~ AA-AA-~
       3        -2        83.0           4.42    0.326  0.00393 Analysis_kri0~ AA-AA-~
       4        -2        85.8           4.45    0.453  0.00528 Analysis_kri0~ AA-AA-~
       5        -2        88.6           4.48    0.581  0.00656 Analysis_kri0~ AA-AA-~
       6        -2        91.4           4.52    0.711  0.00778 Analysis_kri0~ AA-AA-~
       7        -2        94.2           4.55    0.843  0.00895 Analysis_kri0~ AA-AA-~
       8        -2        97.1           4.58    0.977  0.0101  Analysis_kri0~ AA-AA-~
       9        -2        99.9           4.60    1.11   0.0111  Analysis_kri0~ AA-AA-~
      10        -2       103.            4.63    1.25   0.0122  Analysis_kri0~ AA-AA-~
      # i 11,487 more rows
      # i 1 more variable: SnapshotDate <date>

