use aoc_2024::read_rows_from_file;

fn main() {
    let eqs = read_rows_from_file("data/day7.txt");

    let n = num_possible(&eqs);
    println!("Part A: The sum of possible equation results is {n:?}");
}

#[derive(Clone)]
enum Operation {
    Add,
    Mul,
    Concat,
}

impl Operation {
    fn calc(&self, a: u64, b: u64) -> u64 {
        match self {
            Operation::Add => a + b,
            Operation::Mul => a * b,
            Operation::Concat => format!("{a}{b}").parse().unwrap(),
        }
    }
}

fn num_possible(equations: &[String]) -> u64 {
    equations.iter().filter_map(|x| parse_and_check(x)).sum()
}

fn parse_and_check(equation: &str) -> Option<u64> {
    let (result, args) = equation.split_once(':').unwrap();
    let result: u64 = result.parse().unwrap();

    let args: Vec<u64> = args.trim().split(' ').map(|x| x.parse().unwrap()).collect();

    if is_feasible(result, &args) {
        Some(result)
    } else {
        None
    }
}

fn is_feasible(result: u64, args: &[u64]) -> bool {
    generate_op_combinations(args.len() - 1)
        .iter()
        .map(|comb| apply(args, comb))
        .filter(|x| *x == result)
        .count()
        > 0
}

fn apply(args: &[u64], ops: &Vec<Operation>) -> u64 {
    let first = args[0];
    args[1..]
        .iter()
        .zip(ops)
        .fold(first, |acc, (num, op)| op.calc(acc, *num))
}

fn generate_op_combinations(n: usize) -> Vec<Vec<Operation>> {
    if n < 1 {
        panic!("invaild argument: {n}");
    }
    if n == 1 {
        vec![
            vec![Operation::Add],
            vec![Operation::Mul],
            vec![Operation::Concat],
        ]
    } else {
        let combs = generate_op_combinations(n - 1);
        // + + +
        //     *
        // + * +
        //     *
        //  ...
        let mut all_combs = vec![];
        for op in [Operation::Add, Operation::Mul, Operation::Concat] {
            for comb in combs.iter() {
                let mut copy = comb.clone();
                copy.push(op.clone());
                all_combs.push(copy);
            }
        }

        all_combs
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_num_possible() {
        let data = "\
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20";

        let equations: Vec<String> = data.lines().map(String::from).collect();

        // without concat: assert_eq!(num_possible(&equations), 3749);
        // with Concat
        assert_eq!(num_possible(&equations), 11387);
    }
}
