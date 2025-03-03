use aoc_2024::TwoDimVec;

fn main() {
    let data = TwoDimVec::read_columns("data/day1.txt");
    let dist = total_distance(&data);
    let sim = total_similarity(&data);

    println!("Part A: The total distance is {dist} and the total similarity is {sim}");
}


fn total_distance(matrix: &TwoDimVec<u64>) -> u64 {
    matrix.ensure_non_empty_matrix();
    let lists = matrix.values.clone();
    let mut lists_sorted = lists.clone();
    lists_sorted.iter_mut().for_each(|list| list.sort());

    let mut result = 0;
    for i in 0..lists_sorted[0].len() {
        let mut min_value = lists_sorted[0][i];
        let mut max_value = lists_sorted[0][i];
        for j in 1..lists_sorted.len() {
            min_value = std::cmp::min(min_value, lists_sorted[j][i]);
            max_value = std::cmp::max(max_value, lists_sorted[j][i]);
        }


        result += max_value - min_value;
    }

    result
}

fn total_similarity(matrix: &TwoDimVec<u64>) -> u64 {
    matrix.ensure_non_empty_matrix();
    let left_list = &matrix.values[0];
    let mut right_list_sorted = matrix.values[1].clone();
    right_list_sorted.sort();

    let mut result = 0;
    for element in left_list {
        let score: u64 = right_list_sorted.iter()
            .filter(|&candidate| candidate == element)
            .count() as u64;

        result += score * element;
    }
    
    result
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_list_distance() {
        let left_list = vec![3, 4, 2, 1, 3, 3];
        let right_list = vec![4, 3, 5, 3, 9, 3];

        let matrix = TwoDimVec::new(vec![left_list, right_list]);
        assert_eq!(total_distance(&matrix), 11);
    }

    #[test]
    fn test_similarity() {
        let left_list = vec![3, 4, 2, 1, 3, 3];
        let right_list = vec![4, 3, 5, 3, 9, 3];

        let matrix = TwoDimVec::new(vec![left_list, right_list]);
        assert_eq!(total_similarity(&matrix), 31);
    }

}
