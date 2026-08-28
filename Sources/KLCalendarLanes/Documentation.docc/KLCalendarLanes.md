# ``KLCalendarLanes``

Deterministic calendar-grid lane allocation for multi-day all-day event bars.

## Build the layout

Give ``KLCalendarLaneEngine/layout`` host-owned ``KLCalendarLaneEvent`` values,
a ``Calendar``, and a visible date interval. The engine normalizes each event
to calendar boundaries, clips it to the interval, and assigns the first lane
that does not overlap another event. It splits a bar whenever a calendar row
ends, returning ``KLCalendarLaneSegment`` values that a grid can render
without reproducing the overlap algorithm.

``KLCalendarLaneLayout/segments(startingOn:)`` returns bars that begin on a
given day. ``KLCalendarLaneLayout/coveredLaneCount(on:)`` tells the host how
much vertical space to reserve for bars crossing that day. Event titles,
colors, tap targets, and single-day cell content remain outside this package.

Choose ``KLEventEndBoundary/exclusive`` when an event ending exactly at the
start of a day must not cover that day. Choose `.inclusive` when the end day is
part of the event. `sortKey` is a deterministic tie-breaker and must be unique
when otherwise equivalent events would compare the same.

## Overview

`KLCalendarLanes` accepts host-owned event IDs and date ranges, normalizes coverage with a supplied `Calendar`, clips it to a half-open layout interval, allocates the first non-overlapping lane, and splits bars at row boundaries.

`sortKey` is part of the total ordering contract. When two multi-day events have the same normalized coverage duration and start day and the same reflected ID text, their `sortKey` values must differ. The engine rejects ambiguous collisions before lane allocation rather than using input order.

It does not render UI, store event titles or colors, or depend on HorizonCalendar. A host renders `segments(startingOn:)` and reserves vertical range-bar space using `coveredLaneCount(on:)`.

For ``KLEventEndBoundary/exclusive``, an event whose end is exactly the start of a day does not cover that day. Use ``KLEventEndBoundary/inclusive`` when the end day must always remain covered.

## Topics

### Building a layout

- ``KLCalendarLaneEngine``
- ``KLCalendarLaneConfiguration``
- ``KLCalendarLaneEvent``
- ``KLEventEndBoundary``

### Reading results

- ``KLCalendarLaneLayout``
- ``KLCalendarLaneSegment``
