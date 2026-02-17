const std = @import("std");
const dbg = std.debug.print;

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

    fn print_board(self: *const Board) void {
        for (self.data) |row| {
            for (row) |cell| {
                dbg("{d:>5} ", .{cell});
            }
            dbg("\n", .{});
        }
    }

    fn perform_action(self: *Board, action: Action) void {
        _ = action;
        // assume action is left
        for (&self.data) |*row| {
            // compute offset and shift
            var offset: ?usize = null;
            var shift: usize = 0;
            for (row, 0..) |cell, i| {
                if (offset == null and cell == 0) offset = i;
                if (offset != null) shift += 1;
                if (offset != null and cell != 0) break;
            }
            if (offset != null) {
                // shift towards free cells
                for (offset.?..row.len - shift) |k| {
                    row[k] = row[k + shift];
                    row[k + shift] = 0;
                }
                // merge identical cells and shift by one
                if (row[0] == row[1]) {
                    row[0] *= 2;
                    for (0..row.len - shift - 1) |k| {
                        row[k] = row[k + 1];
                        row[k + 1] = 0;
                    }
                }
            }
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
    var board = Board{ .curr_row = 0 };
    try build_board(&board);
    const action = try get_action();
    board.print_board();
    board.perform_action(action);
    board.print_board();
}
