#include "MarkRange.h"

namespace DB
{

namespace ErrorCodes
{
    extern const int LOGICAL_ERROR;
}

bool MarkRange::operator==(const MarkRange & rhs) const
{
    return begin == rhs.begin && end == rhs.end;
}

bool MarkRange::operator<(const MarkRange & rhs) const
{
    /// We allow only consecutive non-intersecting ranges
    /// Here we check whether a beginning of one range lies inside another range
    /// (ranges are intersect)
    if (this != &rhs)
    {
        const bool is_intersection = (begin <= rhs.begin && rhs.begin < end) ||
            (rhs.begin <= begin && begin < rhs.end);

        if (is_intersection)
            throw Exception(
                ErrorCodes::LOGICAL_ERROR,
                "Intersecting mark ranges are not allowed, it is a bug! "
                "First range ({}, {}), second range ({}, {})",
                begin, end, rhs.begin, rhs.end);
    }

    return begin < rhs.begin && end <= rhs.begin;
}

size_t getLastMark(const MarkRanges & ranges)
{
    size_t current_task_last_mark = 0;
    for (const auto & mark_range : ranges)
        current_task_last_mark = std::max(current_task_last_mark, mark_range.end);
    return current_task_last_mark;
}

std::string toString(const MarkRanges & ranges)
{
    std::string result;
    for (const auto & mark_range : ranges)
    {
        if (!result.empty())
            result += ", ";
        result += "(" + std::to_string(mark_range.begin) + ", " + std::to_string(mark_range.end) + ")";
    }
    return result;
}

void assertSortedAndNonIntersecting(const MarkRanges & ranges)
{
    MarkRanges ranges_copy(ranges.begin(), ranges.end());
    /// Should also throw an exception if interseting range is found during comparison.
    std::sort(ranges_copy.begin(), ranges_copy.end());
    if (ranges_copy != ranges)
        throw Exception(
            ErrorCodes::LOGICAL_ERROR, "Expected sorted and non intersecting ranges. Ranges: {}",
            toString(ranges));
}

}
