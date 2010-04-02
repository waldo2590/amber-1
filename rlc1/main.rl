(%
 % rowl - generation 1
 % Copyright (C) 2010 nineties
 %
 % $Id: main.rl 2010-04-03 00:39:02 nineties $
 %);

include(stddef, code);

export main;

progname : NULL;

(% rename xxx.rl to xxx.p1 %);
change_suffix: (p0, p1) {
    allocate(3);
    x0 = strlen(p0);
    x1 = strlen(p1);
    x2 = memalloc(x0 - 2 + x1 + 1);
    memcpy(x2, p0, x0 - 2);
    memcpy(x2 + x0 - 2, p1, x1);
    wch(x2, x0 - 2 + x1, '\0');
    return x2;
};

(% p0: asm filename, p1: rowl filename %);
compile: (p0, p1) {
    allocate(2);

    init_typing();

    puts("compile ");
    puts(p1);
    putc('\n');

    (% lex and parse %);
    x0 = open_in(p1);
    puts("> parsing...\n");
    x1 = parse(p1, x0);
    close_in(x0);

    (% type check %);
    puts("> typing...\n");
    typing(x1);

    (% translate to two address code %);
    puts("> translating to tcode...\n");
    x1 = tcodegen(x1);

    (% generate assembly %);
    puts("> generating assembly...\n");
    x0 = open_out(p0);
    asmgen(x0, x1);
    close_out(x0);
    puts("finished\n");
};

ascmd: ["/usr/bin/as", NULL, "-o", NULL, NULL];
(% p0: object filename, p1: asm filename %);
assemble: (p0, p1) {
    allocate(1);
    x0 = fork(); (% pid %);
    if (x0 == 0) {
	(% child %);
	ascmd[1] = p1;
	ascmd[3] = p0;
	execve(ascmd[0], ascmd, 0);
    } else {
	waitpid(-1, &x1, 0);
    };
};

(% p0: argc, p1: argv %);
main: (p0, p1) {
    allocate(3);

    progname = strdup(p1[0]);

    x0 = 1;
    while (x0 < p0) {
	x1 = change_suffix(p1[x0], "s"); (% name of assembly source file %);
	x2 = change_suffix(p1[x0], "o"); (% name of object file %);

	unlink(x1);
	unlink(x2);

        compile(x1, p1[x0]);
	assemble(x2, x1);
        x0 = x0 + 1;
    };
    exit(0);
};
