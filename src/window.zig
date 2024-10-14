const c = @cImport({
    @cInclude("fenster.c");
});

pub fn sleep() void {
    _ = c.fenster_time();
}
