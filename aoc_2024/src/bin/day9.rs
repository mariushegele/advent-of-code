use aoc_2024::read_file_to_string;
use std::fmt;

fn main() {
    let disk_map_raw = read_file_to_string("data/day9.txt");
    let disk_map = disk_map_raw.trim();

    let sum = filesystem_checksum(&disk_map, true);
    println!("Part A: The fragmented filesystem checksum is {sum:?}");

    let sum = filesystem_checksum(&disk_map, false);
    println!("Part B: The unfragmented filesystem checksum is {sum:?}");
}

type Id = u64;
type Size = u64;

#[derive(Debug)]
struct Disk {
    disk: Vec<Option<Id>>,
}

impl Disk {
    fn from_map(disk_map: &DiskMap) -> Self {
        // println!("digits: {disk_map:?} n: {num_blocks_unsorted}");
        let mut disk = vec![None; disk_map.num_blocks_unsorted() as usize];
        let mut disk_index: usize = 0;

        for entry in disk_map.map.iter() {
            match entry {
                &DiskEntry::File(id, region_length) => {
                    Self::set_region_value(&mut disk, disk_index, region_length, Some(id));
                }
                &DiskEntry::Free(region_length) => {
                    Self::set_region_value(&mut disk, disk_index, region_length, None);
                }
            }

            disk_index = disk_index + entry.size() as usize;
        }

        Self { disk }
    }

    fn set_region_value(disk: &mut Vec<Option<u64>>, from: usize, len: u64, value: Option<u64>) {
        let len = len as usize;
        let region: Vec<Option<u64>> = vec![value; len];
        disk[from..from + len].copy_from_slice(&region);
    }

    fn sort_to_left(&mut self) {
        let mut left_most_free: usize = 0;
        let mut right_most_item: usize = self.disk.len() as usize - 1;

        while right_most_item > left_most_free {
            // find first free entry
            while self.disk[left_most_free].is_some() {
                left_most_free += 1
            }
            // find last item
            while self.disk[right_most_item].is_none() {
                right_most_item -= 1;
            }
            if left_most_free >= right_most_item {
                break;
            }

            assert!(self.disk[left_most_free].is_none());
            assert!(self.disk[right_most_item].is_some());
            self.disk.swap(left_most_free, right_most_item);

            left_most_free += 1;
            right_most_item -= 1;
        }
        // println!("sorted disk {disk:?}");
    }

    fn checksum(&self) -> u64 {
        self.disk
            .iter()
            .enumerate()
            .map(|(i, e)| if let Some(id) = e { id * i as u64 } else { 0 })
            .sum()
    }
}

impl fmt::Display for Disk {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        for entry in self.disk.iter() {
            match entry {
                None => write!(f, ".")?,
                Some(id) => write!(f, "{}", id)?,
            }
        }
        Ok(())
    }
}

#[derive(Debug, Clone)]
enum DiskEntry {
    Free(Size),
    File(Id, Size),
}

impl DiskEntry {
    fn size(&self) -> u64 {
        match self {
            Self::Free(a) => *a,
            Self::File(_id, a) => *a,
        }
    }
}

#[derive(Debug, Clone)]
struct DiskMap {
    map: Vec<DiskEntry>,
}

impl DiskMap {
    fn from_str(disk_map: &str) -> Self {
        let (map, _is_file, _next_file_id) = disk_map
            .chars()
            .map(|c| c.to_digit(10).expect("invalid input") as u64)
            .fold(
                (Vec::new(), true, 0),
                |(mut map, is_file, mut next_file_id), entry_len| {
                    let entry = if is_file {
                        let current_id = next_file_id;
                        next_file_id += 1;
                        DiskEntry::File(current_id, entry_len)
                    } else {
                        DiskEntry::Free(entry_len)
                    };

                    map.push(entry);
                    (map, !is_file, next_file_id)
                },
            );

        Self { map: map }
    }

    fn num_blocks_unsorted(&self) -> u64 {
        // 2333133121414131402
        // = 00...111...2...333.44.5555.6666.777.888899
        self.map.iter().map(|entry| entry.size()).sum()
    }

    fn sort_whole_files_to_left(&mut self) {
        /*
        00...111...2...333.44.5555.6666.777.888899
        0099.111...2...333.44.5555.6666.777.8888..
        0099.1117772...333.44.5555.6666.....8888..
        0099.111777244.333....5555.6666.....8888..
        00992111777.44.333....5555.6666.....8888..
         */
        for entry_to_move in (0..self.map.len()).rev() {
            let current_entry = self.map[entry_to_move].clone();

            match current_entry {
                DiskEntry::Free(_) => { /* nothing to do */ }
                DiskEntry::File(id, required_size) => {
                    match self.search_first_free_space_left_of(entry_to_move, required_size) {
                        None => { /* can't move file */ }
                        Some((free_index, free_space)) => {
                            self.move_file(
                                (entry_to_move, id, required_size),
                                (free_index, free_space),
                            );
                        }
                    }

                    // let disk = Disk::from_map(&self);
                    // println!("after moving: {current_entry:?} -> {disk}");
                }
            }
        }
    }

    fn search_first_free_space_left_of(
        &self,
        left_of: usize,
        required_size: Size,
    ) -> Option<(usize, Size)> {
        self.map[0..left_of]
            .iter()
            .enumerate()
            .skip_while(|(_i, entry)| match entry {
                DiskEntry::File(_, _) => true,
                DiskEntry::Free(free_space) => *free_space < required_size,
            })
            .next()
            .map(|(i, entry)| (i, entry.size()))
    }

    fn move_file(&mut self, file_to_move: (usize, Id, Size), free_entry: (usize, Size)) {
        let (entry_index, file_id, required_size) = file_to_move;
        let (free_index, free_space) = free_entry;

        assert!(free_space >= required_size);

        // 00...111..22
        // 0022.111....
        self.map[entry_index] = DiskEntry::Free(required_size);
        self.map[free_index] = DiskEntry::File(file_id, required_size);
        let space_left = free_space - required_size;
        if space_left > 0 {
            self.map.insert(free_index + 1, DiskEntry::Free(space_left));
        }
    }
}

fn filesystem_checksum(disk_map_str: &str, with_fragmentation: bool) -> u64 {
    let mut map = DiskMap::from_str(disk_map_str);
    // println!("Disk map input: {map:?}");
    if with_fragmentation {
        let mut disk = Disk::from_map(&map);
        disk.sort_to_left();
        disk.checksum()
    } else {
        map.sort_whole_files_to_left();
        let disk = Disk::from_map(&map);
        // println!("compacted disk: {disk}");
        disk.checksum()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_num_unique_antinodes() {
        let disk_map = String::from("2333133121414131402");

        assert_eq!(filesystem_checksum(&disk_map, true), 1928);
        assert_eq!(filesystem_checksum(&disk_map, false), 2858);
    }
}
