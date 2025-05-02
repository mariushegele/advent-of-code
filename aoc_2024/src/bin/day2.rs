use aoc_2024::TwoDimVec;
use std::cmp::Ordering;

fn main() {
    let data = TwoDimVec::read_rows("data/day2.txt", " ");
    let n_a = num_safe_reports(&data, false);
    let n_b = num_safe_reports(&data, true);

    println!("Part A: The number of safe reports is {n_a}. With dampener: {n_b}");
}


fn num_safe_reports(matrix: &TwoDimVec<u64>, dampener: bool) -> usize {
    let safe_reports: Vec<&Vec<u64>> = matrix.iter_rows()
        .filter(|row| is_safe(row, dampener))
        .collect();


    safe_reports.len()
}

fn is_safe(values: &Vec<u64>, dampener: bool) -> bool {
    assert!(values.len() >= 2);
    let invalid_index = first_invalid_index(values);
    if invalid_index.is_none() {
        return true;
    }

    if !dampener {
        return false;
    }


    for i in 0..values.len() {
        let mut candidate = values.clone();
        candidate.remove(i);
        let invalid_index = first_invalid_index(&candidate);
        if invalid_index == None {
            return true;
        }
    }

    return false;
}

fn first_invalid_index(candidates: &Vec<u64>) -> Option<usize> {
    let mut direction: Option<Ordering> = None;
    for (i, window) in candidates.windows(2).enumerate() {
        match is_safe_pair(window[0], window[1], direction) {
            None => {
                // invalid pair
                return Some(i);
            },
            Some(dir) => {direction = Some(dir);}
        }
    }

    None
}

fn is_safe_pair(last: u64, current: u64, direction: Option<Ordering>) -> Option<Ordering> {
    let diff = current.abs_diff(last);
    if diff < 1 || diff > 3 {
        return None;
    }

    let pair_direction = current.cmp(&last);
    if pair_direction == Ordering::Equal {
        return None;
    }

    match direction {
        Some(dir) => {
            if dir != pair_direction {
                return None;
            }
        },
        _ => ()
    }

    Some(pair_direction)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_safety() {
        let data = "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
1 9 2 4 5
2 1 2 3 4";

        let data = TwoDimVec::read_rows_from_string(&data, " ");
        assert_eq!(num_safe_reports(&data, false), 2);
        assert_eq!(num_safe_reports(&data, true), 6);
    }

}
