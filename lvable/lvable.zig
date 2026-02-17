const std = @import("std");

pub fn main() !void {
    // Create readers/writers
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    // Create string buffer
    var buffer: [5e5 + 10]u8 = undefined;
    // Get input
    _ = try stdin.readUntilDelimiterOrEof(&buffer, '\n');
    const input = (try stdin.readUntilDelimiterOrEof(&buffer, '\n')).?;
    // Compute moves
    var one_move = false;
    const moves: u4 = for (0..input.len) |i| {
        if (!(i + 1 == input.len) and input[i] == 'l' and input[i + 1] == 'v') break 0;
        if (input[i] == 'l' or input[i] == 'v') one_move = true;
    } else if (one_move) 1 else 2;
    // Output result
    try stdout.print("{d}\n", .{moves});
}
