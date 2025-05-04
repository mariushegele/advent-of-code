use std::fmt::Debug;
use std::fs;
use std::iter::{repeat, zip};
use std::slice::Iter;
use std::str::FromStr;

pub fn read_rows_from_file(file_path: &str) -> Vec<String> {
    fs::read_to_string(file_path)
        .expect("Should have been able to read file")
        .lines()
        .map(String::from)
        .collect()
}

pub fn read_file_to_string(file_path: &str) -> String {
    fs::read_to_string(file_path).expect("Should have been able to read file")
}

#[derive(Clone)]
pub struct TwoDimVec<T: Clone + Default> {
    pub values: Vec<Vec<T>>,
}

impl<T: Clone + Default + FromStr + PartialEq> TwoDimVec<T>
where
    <T as FromStr>::Err: Debug,
{
    pub fn new(values: Vec<Vec<T>>) -> Self {
        Self { values }
    }

    pub fn read_columns(file_path: &str, column_delimiter: &str) -> Self {
        Self::read_rows(file_path, column_delimiter).transpose()
    }

    pub fn read_rows(file_path: &str, column_delimiter: &str) -> Self {
        let contents = fs::read_to_string(file_path).expect("Should have been able to read file");

        Self::read_rows_from_string(&contents, column_delimiter)
    }

    pub fn read_rows_from_string(contents: &str, column_delimiter: &str) -> Self {
        let values: Vec<Vec<T>> = contents
            .split('\n')
            .filter(|line| !line.trim().is_empty())
            .map(|line| {
                line.split(column_delimiter)
                    .filter(|&element| !element.is_empty())
                    .map(|element| element.parse::<T>().expect("failed to parse element"))
                    .collect()
            })
            .collect();

        TwoDimVec { values }
    }

    pub fn at(&self, x: usize, y: usize) -> T {
        self.values[x][y].clone()
    }

    pub fn get(&self, x: usize, y: usize) -> Option<&T> {
        if let Some(row) = self.values.get(x) {
            row.get(y)
        } else {
            None
        }
    }

    pub fn get_mut(&mut self, x: usize, y: usize) -> Option<&mut T> {
        if let Some(row) = self.values.get_mut(x) {
            row.get_mut(y)
        } else {
            None
        }
    }

    pub fn slice(&self, xs: &[usize], ys: &[usize]) -> Vec<T> {
        zip(xs, ys).map(|(x, y)| self.at(*x, *y)).collect()
    }

    pub fn horizontal_slice(&self, x: usize, ys: &[usize]) -> Vec<T> {
        zip(repeat(x), ys).map(|(x, y)| self.at(x, *y)).collect()
    }

    pub fn vertical_slice(&self, xs: &[usize], y: usize) -> Vec<T> {
        zip(xs, repeat(y)).map(|(x, y)| self.at(*x, y)).collect()
    }

    pub fn ensure_non_empty_matrix(&self) -> Option<&Self> {
        if self.n() == 0 {
            panic!("no rows given");
        }

        let m = self.values[0].len();
        if m == 0 {
            panic!("first row empty");
        }
        let row_lengths = self.iter_rows().map(|row| row.len());
        let min = row_lengths.clone().min().unwrap();
        let max = row_lengths.max().unwrap();
        if min != max {
            panic!("row widths don't match");
        }

        Some(self)
    }

    pub fn iter_rows(&self) -> Iter<'_, Vec<T>> {
        self.values.iter()
    }

    pub fn enumerate_values(&self) -> impl Iterator<Item = (usize, usize, &T)> {
        self.values
            .iter()
            .enumerate()
            .flat_map(|(i, row)| row.iter().enumerate().map(move |(j, value)| (i, j, value)))
        // .collect()
    }

    pub fn n(&self) -> usize {
        self.values.len()
    }

    pub fn m(&self) -> usize {
        self.ensure_non_empty_matrix();
        self.values[0].len()
    }

    #[allow(clippy::needless_range_loop)]
    fn transpose(&self) -> Self {
        self.ensure_non_empty_matrix();
        let m = self.values[0].len();
        let mut result: Vec<Vec<T>> = vec![vec![T::default(); self.n()]; m];
        for i in 0..self.n() {
            for j in 0..m {
                result[j][i] = self.values[i][j].clone();
            }
        }

        TwoDimVec { values: result }
    }

    pub fn first_matching_index(&self, options: &[T]) -> Option<(usize, usize, &T)> {
        self.enumerate_values()
            .find(|(_i, _j, v)| options.contains(v))
    }
}
