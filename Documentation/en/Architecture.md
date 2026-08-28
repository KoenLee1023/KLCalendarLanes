# Architecture

The engine normalizes event dates to calendar days, rejects single-day events from range-bar placement, clips multi-day coverage to the requested half-open interval, and sorts by total coverage duration, start date, stable ID text, then `sortKey`. It rejects an exact collision of those four ordering keys before allocation, so accepted inputs have no input-order tie. It assigns the first lane with no occupied day overlap and splits placed events at row boundaries. No event title, color, UI framework, or host model enters the algorithm.
