const std = @import("std");

const Action = enum { Left, Up, Right, Down };

const Board = struct {
    data: [4][4]u16 = undefined,
    curr_row: usize = 0,

    fn add_row(self: *Board, row_data: [4]u16) void {
        if (self.curr_row < 4) {
            self.data[self.curr_row] = row_data;
            self.curr_row += 1;
        }
    }

    // Pass in any writer (stdout, a file, etc.)
    fn print_board(self: *const Board, writer: anytype) !void {
        for (self.data) |row| {
            for (row) |cell| {
                // try writer.print("{d:>5} ", .{cell}); // pretty ^-^
                try writer.print("{d} ", .{cell});
            }
            try writer.print("\n", .{});
        }
    }

    fn perform_action(self: *Board, action: Action) void {
        // Transform board so the requested move becomes a 'Left' move
        match_transform(self, action, true);
        // Perform the Left Shift logic on every row
        for (&self.data) |*row| {
            var new_row = [4]u16{ 0, 0, 0, 0 };
            var write_idx: usize = 0;
            var last_val: u16 = 0;

            for (row) |cell| {
                if (cell == 0) continue;

                if (last_val == cell) {
                    new_row[write_idx - 1] *= 2;
                    last_val = 0; // Reset so [4, 4, 4, 4] becomes [8, 8, 0, 0]
                } else {
                    new_row[write_idx] = cell;
                    last_val = cell;
                    write_idx += 1;
                }
            }
            row.* = new_row;
        }
        // Transform the board back to its original orientation
        match_transform(self, action, false);
    }

    fn match_transform(self: *Board, action: Action, forward: bool) void {
        switch (action) {
            .Left => {}, // Already Left
            .Right => reverse_rows(self),
            .Up => transpose(self),
            .Down => {
                if (forward) {
                    transpose(self);
                    reverse_rows(self);
                } else {
                    reverse_rows(self);
                    transpose(self);
                }
            },
        }
    }

    fn transpose(self: *Board) void {
        for (0..4) |i| {
            for (i + 1..4) |j| {
                const temp = self.data[i][j];
                self.data[i][j] = self.data[j][i];
                self.data[j][i] = temp;
            }
        }
    }

    fn reverse_rows(self: *Board) void {
        for (&self.data) |*row| {
            std.mem.reverse(u16, row);
        }
    }
};

fn build_board(board: *Board) !void {
    const stdin = std.io.getStdIn().reader();
    var buffer: [1024]u8 = undefined;

    while (board.curr_row < 4) {
        const line = (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) orelse break;
        var it = std.mem.tokenizeAny(u8, line, " \r\t");

        var row_vals: [4]u16 = undefined;
        var cnt: usize = 0;

        while (it.next()) |token| : (cnt += 1) {
            if (cnt < 4) {
                row_vals[cnt] = try std.fmt.parseInt(u16, token, 10);
            }
        }
        board.add_row(row_vals);
    }
}

fn get_action() !Action {
    const stdin = std.io.getStdIn().reader();
    var buffer: [16]u8 = undefined;
    const line = (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) orelse return error.EndOfStream;
    const val = try std.fmt.parseInt(u4, line, 10);

    return switch (val) {
        0 => .Left,
        1 => .Up,
        2 => .Right,
        3 => .Down,
        else => error.InvalidAction,
    };
}

pub fn main() !void {
    // Initialize board
    var board = Board{ .curr_row = 0 };
    try build_board(&board);
    // Perform action on board
    const action = try get_action();
    board.perform_action(action);
    // Print board
    const stdout = std.io.getStdOut().writer();
    try board.print_board(stdout);
}
