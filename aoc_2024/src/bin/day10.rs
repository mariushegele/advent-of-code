use aoc_2024::{Position, TwoDimVec};
use std::collections::HashMap;

type TopoMap = TwoDimVec<u8>;

fn main() {
    let topo_map = TwoDimVec::read_rows("data/day10.txt", "");

    let sum = sum_of_trailhead_scores(&topo_map, false);
    println!("Part A: The sum of trailhead scores is {sum:?}");

    let sum = sum_of_trailhead_scores(&topo_map, true);
    println!("Part B: The sum of trailhead ratings is {sum:?}");
}

fn sum_of_trailhead_scores(topo_map: &TopoMap, rating: bool) -> u64 {
    topo_map
        .enumerate_values()
        .filter(|(_y, _x, &num)| num == 0)
        .map(|(y, x, _)| get_trailhead_score(topo_map, (y, x), rating))
        .sum()
}

fn get_trailhead_score(topo_map: &TopoMap, pos: Position, rating: bool) -> u64 {
    if rating {
        search_mountains(topo_map, pos, rating).values().sum()
    } else {
        search_mountains(topo_map, pos, rating).len() as u64
    }
}

fn search_mountains(topo_map: &TopoMap, (y, x): Position, rating: bool) -> HashMap<Position, u64> {
    let mut mountains = HashMap::new();
    let value = topo_map.at(y, x);
    if value == 9 {
        mountains.insert((y, x), 1);
        return mountains;
    }

    for (yn, xn) in topo_map.get_neighbours((y, x)) {
        let nvalue = topo_map.at(yn, xn);
        if nvalue == value + 1 {
            for (neighbour_mountain, num_outgoing_trails) in
                search_mountains(topo_map, (yn, xn), rating)
            {
                if mountains.contains_key(&neighbour_mountain) {
                    // new unique trail to known mountain
                    //     . . .O
                    //     ^    .
                    //     |    .
                    // --> * -->.
                    //     ^
                    //     |
                    // this discoves n_outgoing new paths to the mountain

                    let num_incoming_trails = mountains[&neighbour_mountain];
                    mountains.insert(
                        neighbour_mountain,
                        num_incoming_trails + num_outgoing_trails,
                    );
                } else {
                    mountains.insert(neighbour_mountain, num_outgoing_trails);
                }
            }
        }
    }

    mountains
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_trailhead_score() {
        let topo_map = "
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732";
        let topo_map: TopoMap = TwoDimVec::read_rows_from_string(topo_map.trim(), "");

        assert_eq!(sum_of_trailhead_scores(&topo_map, false), 36);
        assert_eq!(sum_of_trailhead_scores(&topo_map, true), 81);
    }
}
