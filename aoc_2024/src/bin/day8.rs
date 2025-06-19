use aoc_2024::TwoDimVec;
use std::collections::{HashMap, HashSet};

fn main() {
    let map = TwoDimVec::read_rows("data/day8.txt", "");
    let map = AntennaMap::new(&map);

    let n = map.num_unique_antinodes(false);
    println!("Part A: The number of unique antinodes is {n:?}");

    let n = map.num_unique_antinodes(true);
    println!("Part B: The number of unique antinodes is {n:?}");
}

struct AntennaMap<'a> {
    map: &'a TwoDimVec<char>,
}

impl<'a> AntennaMap<'a> {
    fn new(map: &'a TwoDimVec<char>) -> Self {
        map.ensure_non_empty_matrix();

        Self { map }
    }

    fn num_unique_antinodes(&self, resonant: bool) -> usize {
        let frequencies: HashMap<char, Vec<(usize, usize)>> =
            self.get_list_of_antennas()
                .fold(HashMap::new(), |mut acc, (x, y, freq)| {
                    acc.entry(*freq).or_default().push((x, y));

                    acc
                });

        let antinodes: HashSet<(usize, usize)> = frequencies
            .values()
            .map(|antennas| self.get_frequency_antinodes(&antennas, resonant))
            .fold(HashSet::new(), |mut set, antinodes| {
                for antinode in antinodes {
                    set.insert(antinode);
                }

                set
            });

        println!("Antinodes:");
        self.map.display_with_overlay(&antinodes, &'#', &'.');

        antinodes.len()
    }

    fn get_list_of_antennas(&self) -> impl Iterator<Item = (usize, usize, &char)> {
        self.map.enumerate_values().filter(|(_x, _y, c)| **c != '.')
    }

    fn get_frequency_antinodes(
        &self,
        values: &[(usize, usize)],
        resonant: bool,
    ) -> Vec<(usize, usize)> {
        get_unique_pairs(values)
            .iter()
            .flat_map(|(a, b)| self.get_antinodes_of_pair(**a, **b, resonant))
            .collect()
    }

    fn get_antinodes_of_pair(
        &self,
        p1: (usize, usize),
        p2: (usize, usize),
        resonant: bool,
    ) -> Vec<(usize, usize)> {
        if resonant {
            self.get_antinodes_of_pair_resonant(p1, p2)
        } else {
            self.get_antinodes_of_pair_non_resonant(p1, p2)
        }
    }

    fn get_antinodes_of_pair_non_resonant(
        &self,
        p1: (usize, usize),
        p2: (usize, usize),
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

        let mut antinodes = vec![];
        if let Some(p) = self.project(p1, p2, 2) {
            antinodes.push(p);
        }
        if let Some(p) = self.project(p2, p1, 2) {
            antinodes.push(p);
        }
        antinodes
    }

    fn get_antinodes_of_pair_resonant(
        &self,
        p1: (usize, usize),
        p2: (usize, usize),
    ) -> Vec<(usize, usize)> {
        /*         (y, x)
        ..........
        ...#...... (1, 3) = (ya1, xa1) (no resonance)
        ..........
        ....a..... (3, 4) = (y1, x1)
        ..........
        .....a.... (5, 5) = (y2, x2)
        ..........
        ......#... (7, 6) = (yb1, xb1) (no resonance)
        ..........
        .......#.. (9, 7) = (yb1, yb2) (with resonance)

        xa1 = x2 + 2 * (x1 - x2) = 5 + 2 * (4 - 5) = 3
        ya1 = y2 + 2 * (y1 - y2) = 5 + 2 * (3 - 5) = 1

        xa2 = x2 + 2 * (x1 - x2) = 5 + 3 * (4 - 5) = 2
        ya2 = y2 + 2 * (y1 - y2) = 5 + 3 * (3 - 5) = -1 (outside map, not included)

        xb1 = x1 + 2 * (x2 - x1) = 4 + 2 * (5 - 4) = 6
        yb1 = y1 + 2 * (y2 - y1) = 3 + 2 * (5 - 3) = 7

        xb1 = x1 + 3 * (x2 - x1) = 4 + 3 * (5 - 4) = 7
        yb1 = y1 + 3 * (y2 - y1) = 3 + 3 * (5 - 3) = 9

        xb1 = x1 + 3 * (x2 - x1) = 4 + 4 * (5 - 4) = 8
        yb1 = y1 + 3 * (y2 - y1) = 3 + 4 * (5 - 3) = 11 (outside map, not included)
        */

        let mut antinodes = vec![p1, p2];

        antinodes.append(&mut self.project_antinodes_while_in_map(p1, p2));
        antinodes.append(&mut self.project_antinodes_while_in_map(p2, p1));
        antinodes
    }

    fn project_antinodes_while_in_map(
        &self,
        p1: (usize, usize),
        p2: (usize, usize),
    ) -> Vec<(usize, usize)> {
        let mut n: isize = 2;
        let mut antinodes = vec![];
        while let Some(p) = self.project(p2, p1, n) {
            antinodes.push(p);
            n += 1;
        }
        antinodes
    }

    fn project(
        &self,
        (x1, y1): (usize, usize),
        (x2, y2): (usize, usize),
        n: isize,
    ) -> Option<(usize, usize)> {
        assert!(n >= 2);

        let (x1, y1) = (x1 as isize, y1 as isize);
        let (x2, y2) = (x2 as isize, y2 as isize);

        let x = x1 + n * (x2 - x1);
        let y = y1 + n * (y2 - y1);

        if x >= 0 && (x as usize) < self.map.m() && y >= 0 && (y as usize) < self.map.n() {
            Some((x as usize, y as usize))
        } else {
            None
        }
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

        assert_eq!(map.num_unique_antinodes(false), 14);
        assert_eq!(map.num_unique_antinodes(true), 34);
    }
}
