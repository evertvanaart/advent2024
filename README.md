# Advent of Code 2024

Trying out Elixir this time around.

Plain Elixir, no dependencies, simple parallel processing where applicable.

```plain
Usage: mix run main.exs <task> <input>
 <task>     Day number (two digits) plus part ('a' or 'b')
 <input>    Input file base name, e.g. 'input' or 'sample'
 --profile  Run solution multiple times and compute average duration
Example: mix run main.exs 01a sample
```

# Results

The table below shows the average core runtime of each solution, recorded over an average of 20 runs. These times were recorded on a 2021 MacBook Pro using Elixir 1.17.3. The core runtime does not include the time it takes to read the input file and split it into lines, but does include any additional input parsing.

| Day  | Part A (μs) | Part B (μs) |
| :--: | ----------: | ----------: |
|  01  |       6,501 |       6,810 |
|  02  |       6,785 |       6,967 |
|  03  |         460 |         309 |
|  04  |      10,661 |       6,971 |
|  05  |       2,944 |       3,799 |
|  06  |       5,335 |      26,848 |
|  07  |       7,589 |      72,050 |
|  08  |         269 |       1,117 |
|  09  |       6,744 |      15,837 |
|  10  |       3,118 |       3,104 |
|  11  |       3,668 |      52,854 |
|  12  |      24,620 |      32,064 |
|  13  |       1,226 |         756 |
|  14  |         811 |         N/A |
|  15  |       9,896 |      13,322 |
|  16  |      79,716 |     277,957 |
|  17  |       1,995 |       3,909 |
|  18  |       4,819 |      11,578 |
|  19  |      46,949 |      48,798 |
|  20  |      19,604 |     116,959 |
|  21  |       2,194 |         186 |
|  22  |      11,606 |     589,043 |
|  23  |       6,248 |     702,446 |
|  24  |         436 |       2,239 |
|  25  |       1,820 |         --- |

While Elixir is somewhat slower than Go and Rust for basic tasks – especially string splitting seems surprisingly slow – I did manage to keep the runtime below one second for all questions this year. Some solutions use basic parallel processing (pretty much just `Task.async_stream/3`), which usually speeds the solution up by a factor 5 to 10 compared to the single-threaded solution.
