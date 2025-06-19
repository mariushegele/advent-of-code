use aoc_2024::TwoDimVec;
use std::collections::{HashMap, HashSet};

fn main() {
    let map = TwoDimVec::read_rows("data/day8.txt", "");
    let map = AntennaMap::new(&map);

    let n = map.num_unique_antinodes();
    println!("Part A: The number of unique antinodes is {n:?}");
}

struct AntennaMap<'a> {
    map: &'a TwoDimVec<char>,
}

impl<'a> AntennaMap<'a> {
    fn new(map: &'a TwoDimVec<char>) -> Self {
        map.ensure_non_empty_matrix();

        Self { map }
    }

    fn num_unique_antinodes(&self) -> usize {
        let frequencies: HashMap<char, Vec<(usize, usize)>> =
            self.get_list_of_antennas()
                .fold(HashMap::new(), |mut acc, (x, y, freq)| {
                    acc.entry(*freq).or_default().push((x, y));

                    acc
                });

        let antinodes: HashSet<(usize, usize)> = frequencies
            .values()
            .map(|antennas| self.get_frequency_antinodes(&antennas))
            .fold(HashSet::new(), |mut set, antinodes| {
                for antinode in antinodes {
                    set.insert(antinode);
                }

                set
            });

        antinodes.len()
    }

    fn get_list_of_antennas(&self) -> impl Iterator<Item = (usize, usize, &char)> {
        self.map.enumerate_values().filter(|(_x, _y, c)| **c != '.')
    }
    fn get_frequency_antinodes(&self, values: &[(usize, usize)]) -> Vec<(usize, usize)> {
        get_unique_pairs(values)
            .iter()
            .flat_map(|(a, b)| self.get_antinodes_of_pair(**a, **b))
            .collect()
    }

    fn get_antinodes_of_pair(
        &self,
        (x1, y1): (usize, usize),
        (x2, y2): (usize, usize),
    ) -> Vec<(usize, usize)> {
        /*         (y, x)
        ..........
        ...#...... (1, 3) = (ya, xa)
        ..........
        ....a..... (3, 4) = (y1, x1)
        ..........
        .....a.... (5, 5) = (y2, x2)
        ..........
        ......#... (7, 6) = (yb, xb)
        ..........

        xa = x2 + 2 * (x1 - x2) = 5 + 2 * (4 - 5) = 3
        ya = y2 + 2 * (y1 - y2) = 5 + 2 * (3 - 5) = 1

        xb = x1 + 2 * (x2 - x1) = 4 + 2 * (5 - 4) = 6
        yb = y1 + 2 * (y2 - y1) = 3 + 2 * (5 - 3) = 7
        */

        let (x1, y1) = (x1 as isize, y1 as isize);
        let (x2, y2) = (x2 as isize, y2 as isize);

        let xa = x2 + 2 * (x1 - x2);
        let ya = y2 + 2 * (y1 - y2);

        let xb = x1 + 2 * (x2 - x1);
        let yb = y1 + 2 * (y2 - y1);

        let mut antinodes = vec![];
        if xa >= 0 && (xa as usize) < self.map.m() && ya >= 0 && (ya as usize) < self.map.n() {
            antinodes.push((xa as usize, ya as usize));
        }
        if xb >= 0 && (xb as usize) < self.map.m() && yb >= 0 && (yb as usize) < self.map.n() {
            antinodes.push((xb as usize, yb as usize));
        }

        antinodes
    }
}

fn get_unique_pairs<T>(values: &[T]) -> Vec<(&T, &T)>
where
    T: Clone,
{
    // 0 1
    // 0 2
    // ...
    // 0 n-1
    // 1 2
    // 1 3
    // 1 n-1

    let n = values.len();
    let mut pairs = vec![];
    for i in 0..n {
        for j in i + 1..n {
            pairs.push((&values[i], &values[j]))
        }
    }

    pairs
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_num_unique_antinodes() {
        let data = "\
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............";

        let map = TwoDimVec::read_rows_from_string(data, "");
        let map = AntennaMap::new(&map);

        assert_eq!(map.num_unique_antinodes(), 14);
    }
}
