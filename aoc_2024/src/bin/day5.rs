use aoc_2024::read_file_to_string;
use std::collections::{HashMap, HashSet};

fn main() {
    let rules_and_updates = read_file_to_string("data/day5.txt");

    let sum = sum_of_correct_update_ids(&rules_and_updates, false);
    println!("Part A: The sum of correct update IDs is {sum}");

    let sum = sum_of_correct_update_ids(&rules_and_updates, true);
    println!("Part B: The sum of fixed update IDs is {sum}");
}

fn sum_of_correct_update_ids(rules_and_updates: &str, fix: bool) -> u32 {
    let rules: Vec<(u32, u32)> = rules_and_updates
        .trim()
        .lines()
        .take_while(|line| !line.is_empty())
        .map(parse_rule)
        .collect();

    let updates: Vec<Vec<u32>> = rules_and_updates
        .trim()
        .lines()
        .skip_while(|line| !line.is_empty())
        .skip(1)
        .map(parse_update)
        .collect();

    let successor_map = build_successor_map(&rules);

    let (valid, invalid): (Vec<_>, Vec<_>) = updates
        .iter()
        .partition(|update| is_valid(update, &successor_map));

    if !fix {
        valid.iter().map(|update| get_middle_element(update)).sum()
    } else {
        invalid
            .iter()
            .map(|update| make_valid(update, &successor_map))
            .map(|update| get_middle_element(&update))
            .sum()
    }
}

fn parse_rule(rule: &str) -> (u32, u32) {
    let v: Vec<u32> = rule.split('|').map(|n| n.parse().unwrap()).collect();
    (v[0], v[1])
}

fn parse_update(update: &str) -> Vec<u32> {
    update.split(',').map(|n| n.parse().unwrap()).collect()
}

fn build_successor_map(rules: &[(u32, u32)]) -> HashMap<u32, HashSet<u32>> {
    let mut successor_map: HashMap<u32, HashSet<u32>> = HashMap::new();
    for (node, successor) in rules {
        successor_map.entry(*node).or_default().insert(*successor);
    }

    successor_map
}

fn is_valid(update: &[u32], successor_map: &HashMap<u32, HashSet<u32>>) -> bool {
    let mut seen: HashSet<u32> = HashSet::new();

    let mut valid = true;
    for node in update.iter() {
        if let Some(successors) = successor_map.get(node) {
            if seen.intersection(successors).count() > 0 {
                valid = false;
                break;
            }
        }

        seen.insert(*node);
    }

    valid
}

fn make_valid(update: &[u32], successor_map: &HashMap<u32, HashSet<u32>>) -> Vec<u32> {
    let mut pool: HashSet<u32> = HashSet::from_iter(update.iter().cloned());
    let mut valid = Vec::new();

    while !pool.is_empty() {
        let leaf = find_leaf(&pool, successor_map);

        valid.insert(0, leaf);
        pool.remove(&leaf);
    }

    valid
}

fn find_leaf(pool: &HashSet<u32>, successor_map: &HashMap<u32, HashSet<u32>>) -> u32 {
    for node in pool {
        match successor_map.get(node) {
            None => return *node,
            Some(successors) => {
                if successors.intersection(pool).count() == 0 {
                    return *node;
                }
            }
        }
    }

    panic!("failed to find node")
}

fn get_middle_element(update: &[u32]) -> u32 {
    update[update.len() / 2]
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_result() {
        let rules_and_updates = "\
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47";

        assert_eq!(sum_of_correct_update_ids(rules_and_updates, false), 143);
        assert_eq!(sum_of_correct_update_ids(rules_and_updates, true), 123);
    }
}
