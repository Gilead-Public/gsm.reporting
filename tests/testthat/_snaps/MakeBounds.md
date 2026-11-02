# MakeBounds makes dfBounds (#41, #42)

    Code
      MakeBounds(dfResults = dplyr::filter(gsm.core::reportingResults, SnapshotDate ==
        "2025-04-01"), dfMetrics = gsm.core::reportingMetrics)
    Message
      Creating stacked dfBounds data for strMetrics
      Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
      nStep was not provided. Setting default step to 3.22.
      Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
      nStep was not provided. Setting default step to 3.22.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 3.22.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 3.22.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 18.348.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.056.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.056.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.056.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 33.792.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 2.112.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 8.448.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 33.792.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 0.072.
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
      # A tibble: 11,356 x 8
         Threshold Denominator LogDenominator Numerator   Metric MetricID      StudyID
             <dbl>       <dbl>          <dbl>     <dbl>    <dbl> <chr>         <chr>  
       1        -2        156.           5.05    0.0889 0.000571 Analysis_kri~ AA-AA-~
       2        -2        159.           5.07    0.221  0.00139  Analysis_kri~ AA-AA-~
       3        -2        162            5.09    0.354  0.00218  Analysis_kri~ AA-AA-~
       4        -2        165.           5.11    0.488  0.00295  Analysis_kri~ AA-AA-~
       5        -2        168.           5.13    0.623  0.00370  Analysis_kri~ AA-AA-~
       6        -2        172.           5.15    0.760  0.00443  Analysis_kri~ AA-AA-~
       7        -2        175.           5.16    0.898  0.00514  Analysis_kri~ AA-AA-~
       8        -2        178.           5.18    1.04   0.00582  Analysis_kri~ AA-AA-~
       9        -2        181.           5.20    1.18   0.00649  Analysis_kri~ AA-AA-~
      10        -2        185.           5.22    1.32   0.00714  Analysis_kri~ AA-AA-~
      # i 11,346 more rows
      # i 1 more variable: SnapshotDate <date>

# MakeBounds uses user-supplied strMetrics (#41)

    Code
      MakeBounds(dfResults = dplyr::filter(gsm.core::reportingResults, SnapshotDate ==
        "2025-04-01"), dfMetrics = gsm.core::reportingMetrics, strMetrics = "Analysis_kri0001")
    Message
      Creating stacked dfBounds data for strMetrics
      Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
      nStep was not provided. Setting default step to 3.22.
    Output
      # A tibble: 1,200 x 8
         Threshold Denominator LogDenominator Numerator   Metric MetricID      StudyID
             <dbl>       <dbl>          <dbl>     <dbl>    <dbl> <chr>         <chr>  
       1        -2        156.           5.05    0.0889 0.000571 Analysis_kri~ AA-AA-~
       2        -2        159.           5.07    0.221  0.00139  Analysis_kri~ AA-AA-~
       3        -2        162            5.09    0.354  0.00218  Analysis_kri~ AA-AA-~
       4        -2        165.           5.11    0.488  0.00295  Analysis_kri~ AA-AA-~
       5        -2        168.           5.13    0.623  0.00370  Analysis_kri~ AA-AA-~
       6        -2        172.           5.15    0.760  0.00443  Analysis_kri~ AA-AA-~
       7        -2        175.           5.16    0.898  0.00514  Analysis_kri~ AA-AA-~
       8        -2        178.           5.18    1.04   0.00582  Analysis_kri~ AA-AA-~
       9        -2        181.           5.20    1.18   0.00649  Analysis_kri~ AA-AA-~
      10        -2        185.           5.22    1.32   0.00714  Analysis_kri~ AA-AA-~
      # i 1,190 more rows
      # i 1 more variable: SnapshotDate <date>

# MakeBounds makes poisson dfBounds (#41)

    Code
      MakeBounds(dfResults = dplyr::filter(gsm.core::reportingResults, SnapshotDate ==
        "2025-04-01"), dfMetrics = reportingMetrics)
    Message
      Creating stacked dfBounds data for strMetrics
      Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
      nStep was not provided. Setting default step to 3.22.
      Parsed -2,-1,2,3 to numeric vector: -2, -1, 2, 3
      nStep was not provided. Setting default step to 3.22.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 3.22.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 3.22.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 18.348.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.056.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.056.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 0.056.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 33.792.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 2.112.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 8.448.
      Parsed 2,3 to numeric vector: 2, 3
      nStep was not provided. Setting default step to 33.792.
      Parsed -3,-2,2,3 to numeric vector: -3, -2, 2, 3
      nStep was not provided. Setting default step to 0.072.
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
      # A tibble: 11,356 x 8
         Threshold Denominator LogDenominator Numerator   Metric MetricID      StudyID
             <dbl>       <dbl>          <dbl>     <dbl>    <dbl> <chr>         <chr>  
       1        -2        156.           5.05    0.0889 0.000571 Analysis_kri~ AA-AA-~
       2        -2        159.           5.07    0.221  0.00139  Analysis_kri~ AA-AA-~
       3        -2        162            5.09    0.354  0.00218  Analysis_kri~ AA-AA-~
       4        -2        165.           5.11    0.488  0.00295  Analysis_kri~ AA-AA-~
       5        -2        168.           5.13    0.623  0.00370  Analysis_kri~ AA-AA-~
       6        -2        172.           5.15    0.760  0.00443  Analysis_kri~ AA-AA-~
       7        -2        175.           5.16    0.898  0.00514  Analysis_kri~ AA-AA-~
       8        -2        178.           5.18    1.04   0.00582  Analysis_kri~ AA-AA-~
       9        -2        181.           5.20    1.18   0.00649  Analysis_kri~ AA-AA-~
      10        -2        185.           5.22    1.32   0.00714  Analysis_kri~ AA-AA-~
      # i 11,346 more rows
      # i 1 more variable: SnapshotDate <date>

