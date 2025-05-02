use aoc_2024::read_file_to_string;
use regex::Regex;

fn main() {
    let instructions = read_file_to_string("data/day3.txt");

    let sum = sum_results(&instructions, false);
    println!("Part A: The sum of results is {sum}");

    let sum = sum_results(&instructions, true);
    println!("Part B: The sum of results is {sum}");
}

fn sum_results(instructions: &str, conditional: bool) -> i64 {
    let re = Regex::new(r"(?<op>mul|don't|do)\(((?<a>\d+),(?<b>\d+))?\)").unwrap();

    let mut sum = 0;
    let mut enabled = true;
    for cap in re.captures_iter(instructions) {
        match &cap["op"] {
            "do" => enabled = true,
            "don't" => enabled = false,
            "mul" => {
                let a = cap["a"].parse::<i64>().unwrap();
                let b = cap["b"].parse::<i64>().unwrap();
                if enabled || !conditional {
                    sum += a * b;
                }
            },
            _ => panic!("impossible"),
        }
    }

    sum
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_result() {
        let instruction = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";

        assert_eq!(sum_results(instruction, false), 161);
        assert_eq!(sum_results(instruction, true), 161);

        let instruction = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";
        assert_eq!(sum_results(instruction, false), 161);
        assert_eq!(sum_results(instruction, true), 48);
    }

}
