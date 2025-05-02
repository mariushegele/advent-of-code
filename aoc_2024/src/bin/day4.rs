use aoc_2024::TwoDimVec;

fn main() {
    let data = TwoDimVec::read_rows("data/day4.txt", "");
    let n = num_symmetric_ocurrences(&data, String::from("XMAS"));

    println!("Part A: The number of ocurrences is {n}");

    let n = num_criss_cross_occurences(&data, String::from("MAS"));
    println!("Part B: The number of ocurrences is {n}");
}


fn num_symmetric_ocurrences(matrix: &TwoDimVec<char>, word: String) -> usize {
    matrix.ensure_non_empty_matrix();
    let n = matrix.n();
    let m = matrix.m();

    let letters: Vec<char> = word.chars().collect();
    let reverse: Vec<char> = word.chars().rev().collect();
    let word_len = letters.len();

    let mut occurences = 0;

    let ns: Vec<usize> = (0..n).collect();
    let ms: Vec<usize> = (0..m).collect();

    // horizontal
    for x in 0..n {
        for y_win in ms.windows(word_len) {
            let slice = matrix.horizontal_slice(x, y_win);
            if slice == letters || slice == reverse {
                occurences += 1;
            }
        }
    }
    
    // vertical
    for x_win in ns.windows(word_len) {
        for y in 0..m {
            let slice = matrix.vertical_slice(x_win, y);
            if slice == letters || slice == reverse {
                occurences += 1;
            }
        }
    }
    
    // diagonal 
    for y_win in ms.windows(word_len) {
        for x_win in ns.windows(word_len) {
            let slice_desc = matrix.slice(x_win, y_win);

            if slice_desc == letters || slice_desc == reverse {
                occurences += 1;
            }

            let x_win_rev: Vec<usize> = x_win.iter().rev().map(|i| *i).collect();
            let slice_asc = matrix.slice(&x_win_rev, y_win);
            if slice_asc == letters || slice_asc == reverse {
                occurences += 1;
            }

        }
    }

    occurences
}

fn num_criss_cross_occurences(matrix: &TwoDimVec<char>, word: String) -> usize {
    matrix.ensure_non_empty_matrix();
    let n = matrix.n();
    let m = matrix.m();

    let letters: Vec<char> = word.chars().collect();
    let reverse: Vec<char> = word.chars().rev().collect();
    let word_len = letters.len();

    let mut occurences = 0;

    let ns: Vec<usize> = (0..n).collect();
    let ms: Vec<usize> = (0..m).collect();

    for y_win in ms.windows(word_len) {
        for x_win in ns.windows(word_len) {
            let slice_desc = matrix.slice(x_win, y_win);
            let x_win_rev: Vec<usize> = x_win.iter().rev().map(|i| *i).collect();
            let slice_asc = matrix.slice(&x_win_rev, y_win);

            if (slice_desc == letters || slice_desc == reverse) && 
                (slice_asc == letters || slice_asc == reverse) {
                occurences += 1;
            }
        }
    }

    occurences
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_xmas() {
        let data = "\
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX";

        let data = TwoDimVec::read_rows_from_string(&data, "");
        assert_eq!(num_symmetric_ocurrences(&data, String::from("XMAS")), 18);
        assert_eq!(num_criss_cross_occurences(&data, String::from("MAS")), 9);
    }

}
