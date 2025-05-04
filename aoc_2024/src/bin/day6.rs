use aoc_2024::TwoDimVec;
use std::collections::{HashMap, HashSet};
use std::fmt::Debug;
use std::iter::zip;

fn main() {
    let map = TwoDimVec::read_rows("data/day6.txt", "");
    let map = Map::new(&map);

    let n = num_distinct_positions_in_guard_path(&map);
    println!("Part A: The number of distinct positions is {n:?}");

    let m = num_loop_obstructions(&map);
    println!("Part B: The number of distinct loop-inducing obstructions is {m:?}");
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum Dir {
    Up,
    Down,
    Right,
    Left,
}

impl Dir {
    fn rotate_clockwise(&self) -> Self {
        match self {
            Self::Up => Self::Right,
            Self::Right => Self::Down,
            Self::Down => Self::Left,
            Self::Left => Self::Up,
        }
    }
}

#[derive(Debug)]
struct GuardState {
    x: usize,
    y: usize,
    dir: Dir,
}

impl GuardState {
    fn simulate_step(&self) -> Option<Self> {
        match self.dir {
            Dir::Up => self
                .x
                .checked_sub(1)
                .map(|new_x| Self { x: new_x, ..*self }),
            Dir::Down => Some(Self {
                x: self.x + 1,
                ..*self
            }),
            Dir::Right => Some(Self {
                y: self.y + 1,
                ..*self
            }),
            Dir::Left => self
                .y
                .checked_sub(1)
                .map(|new_y| Self { y: new_y, ..*self }),
        }
    }
}

struct Map<'a> {
    map: &'a TwoDimVec<char>,
    additional_obstruction: Option<(usize, usize)>,
}

impl<'a> Map<'a> {
    fn new(map: &'a TwoDimVec<char>) -> Self {
        map.ensure_non_empty_matrix();

        Self {
            map,
            additional_obstruction: None,
        }
    }

    fn get(&self, x: usize, y: usize) -> Option<&char> {
        if self.additional_obstruction == Some((x, y)) {
            Some(&'#')
        } else {
            self.map.get(x, y)
        }
    }

    fn get_initial_state(&self) -> GuardState {
        let guard_dir_indicators = vec!['^', 'v', '>', '<'];
        let guard_directions = vec![Dir::Up, Dir::Down, Dir::Right, Dir::Left];

        let (guard_x, guard_y, found_ind) = self
            .map
            .first_matching_index(&guard_dir_indicators)
            .expect("expected guard");

        let initial_direction = zip(guard_dir_indicators, guard_directions)
            .find(|(ind, _dir)| ind == found_ind)
            .map(|(_, dir)| dir)
            .unwrap();

        GuardState {
            x: guard_x,
            y: guard_y,
            dir: initial_direction,
        }
    }

    fn enumerate_values(&self) -> impl Iterator<Item = (usize, usize, &char)> {
        self.map.enumerate_values()
    }
}

fn num_distinct_positions_in_guard_path(map: &Map) -> Option<usize> {
    let mut state: Option<GuardState> = Some(map.get_initial_state());

    let mut hit_positions: HashMap<(usize, usize), HashSet<Dir>> = HashMap::new();
    while state.is_some() {
        let some_state = state.unwrap();
        if !hit_positions
            .entry((some_state.x, some_state.y))
            .or_default()
            .insert(some_state.dir)
        {
            // position and direction already seen -> inifite loop
            return None;
        }
        state = step(&some_state, map);
    }

    Some(hit_positions.len())
}

fn num_loop_obstructions(map: &Map) -> usize {
    let initial_state = map.get_initial_state();
    map.enumerate_values()
        .filter(|(x, y, value)| {
            (*x, *y) != (initial_state.x, initial_state.y)
                && **value != '#'
                && additional_obstruction_leads_to_loop(map, *x, *y)
        })
        .count()
}

fn additional_obstruction_leads_to_loop(map: &Map, x: usize, y: usize) -> bool {
    let new_map: Map = Map {
        map: map.map,
        additional_obstruction: Some((x, y)),
    };
    num_distinct_positions_in_guard_path(&new_map).is_none()
}

fn step(state: &GuardState, map: &Map) -> Option<GuardState> {
    match state.simulate_step() {
        None => None,
        Some(hypothetical_state) => match map.get(hypothetical_state.x, hypothetical_state.y) {
            None => None,
            Some('#') => {
                let rot_state = GuardState {
                    dir: state.dir.rotate_clockwise(),
                    ..*state
                };

                step(&rot_state, map)
            }
            Some(_) => Some(hypothetical_state),
        },
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_guard_path() {
        let data = "\
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...";

        let map = TwoDimVec::read_rows_from_string(data, "");
        let map = Map::new(&map);

        assert_eq!(num_distinct_positions_in_guard_path(&map), Some(41));

        assert_eq!(num_loop_obstructions(&map), 6);
    }
}
