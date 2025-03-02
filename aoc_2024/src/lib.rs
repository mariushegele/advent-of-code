use std::fs;
use std::str::FromStr;
use std::fmt::Debug;


pub struct Matrix<T: Clone + Default> {
    pub values: Vec<Vec<T>>,
}

impl<T: Clone + Default + FromStr> Matrix<T> where <T as FromStr>::Err: Debug {

    pub fn read_columns(file_path: &str) -> Matrix<T> {
        Self::read_rows(file_path).transpose()
    }

    pub fn read_rows(file_path: &str) -> Matrix<T> {
        let contents = fs::read_to_string(file_path)
            .expect("Should have been able to read file");

        let rows: Vec<Vec<T>> = contents.split("\n")
            .filter(|line| line.trim().len() > 0)
            .map(|line| {
                line.split_whitespace()
                .filter(|&element| !element.is_empty())
                .map(|element| {
                    element.parse::<T>().expect("failed to parse element")
                })
                .collect()
            })
            .collect();

        Matrix::new(rows).expect("Error parsing rows matrix")
    }

    pub fn new(matrix: Vec<Vec<T>>) -> Result<Matrix<T>, &'static str> {
        let n = matrix.len();
        if n == 0 {
            return Err("no rows given");
        }

        let m = matrix[0].len();
        if m == 0 {
            return Err("first row empty");
        }
        let row_iters = matrix.iter();
        let row_lengths = row_iters.map(|row| row.len());
        let min = row_lengths.clone().min().unwrap();
        let max = row_lengths.max().unwrap();
        if min != max {
            return Err("row widths don't match");
        }

        Ok( Matrix { values: matrix } )
    }

    fn n(&self) -> usize {
        self.values.len()
    }

    fn m(&self) -> usize {
        self.values[0].len()
    }

    fn transpose(&self) -> Self {
        let mut result: Vec<Vec<T>> = vec![vec![T::default(); self.n()]; self.m()];
        for i in 0..self.n() {
            for j in 0..self.m() {
                result[j][i] = self.values[i][j].clone();
            }
        }

        Matrix {values: result}
    }
}


