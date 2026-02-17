const std = @import("std");
const dbg = @import("std").debug.print;

const ErrStates = error{
    BoardIsFull,
    InvalidAction,
};

const Action = enum { Left, Up, Right, Down };

const Game = struct { board: Board, action: Action };

const Board = struct {
    data: [4][]u16 = undefined,
    curr_row: usize = 0,

    fn add_row(self: *Board, row: []u16) ErrStates!void {
        self.data[self.curr_row] = row;
        self.curr_row += 1;
        if (self.curr_row > 3) return ErrStates.BoardIsFull;
    }

    fn perform_action() !void {}
    
    fn print_board(self: *const Board) void {
        for (0..4) |i| {
            for (self.data[i]) |j| {
                dbg("{d:>4} ", .{j});
            }
            dbg("\n", .{});
        }
    }
};

fn build_board(board: *Board) !void {
    const stdin = std.io.getStdIn().reader();
    var buffer: [128]u8 = undefined;
    row_reader: while (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) |row| {
        var it = std.mem.tokenizeAny(u8, row, " ");
        var res: [4]u16 = undefined;
        var cnt: usize = 0;
        while (it.next()) |item| {
            res[cnt] = item[0];
            cnt += 1;
        }
        board.add_row(&res) catch break :row_reader;
    }
}

fn get_action() !Action {
    const stdin = std.io.getStdIn().reader();
    var buffer: [128]u8 = undefined;
    const action_raw = try stdin.readUntilDelimiterOrEof(&buffer, '\n');
    // const action_trimmed = std.mem.trim(u8, action_raw.?, " \n\r\t");
    // dbg("!!{s}", .{action_raw.?});
    return switch (try std.fmt.parseInt(u4, action_raw.?, 10)) {
        0 => Action.Left,
        1 => Action.Up,
        2 => Action.Right,
        3 => Action.Down,
        else => ErrStates.InvalidAction,
    };
}

pub fn main() !void {
    var board = Board{};
    try build_board(&board);
    const action = try get_action();
    _ = action;
    board.print_board();
}
