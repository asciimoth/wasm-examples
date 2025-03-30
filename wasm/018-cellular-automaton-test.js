const loader = require('../loader');

const circle = ""+
    "   ++   \n"+
    " +    + \n"+
    "+      +\n"+
    "+      +\n"+
    " +    + \n"+
    "   ++   \n"
const circle_pos = [
    [3,0], [4,0],
    [1,1], [6,1],
    [0,2], [7,2],
    [0,3], [7,3],
    [1,4], [6,4],
    [3,5], [4,5],
];

const oscilator = {
    cols: 9,
    rows: 9,
    init: [
        [4,3], [3,4], [4,4], [5,4], [4,5],
    ],
    result: "" +
        "    +    \n"+
        "    +    \n"+
        "    +    \n"+
        "         \n"+
        "+++   +++\n"+
        "         \n"+
        "    +    \n"+
        "    +    \n"+
        "    +    \n",
    after: 7,
    perod: 2,
};


describe('CA', () => {
    test('move', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                extGetCell: () => {},
            },
        });

        const upLeft    = instance.exports.upLeft.value;
        const up        = instance.exports.up.value;
        const upRight   = instance.exports.upRight.value;
        const right     = instance.exports.right.value;
        const downRight = instance.exports.downRight.value;
        const down      = instance.exports.down.value;
        const downLeft  = instance.exports.downLeft.value;
        const left      = instance.exports.left.value;

        const moves = [
            [upLeft,    [-1, -1]],
            [up,        [ 0, -1]],
            [upRight,   [+1, -1]],
            [right,     [+1,  0]],
            [downRight, [+1, +1]],
            [down,      [ 0, +1]],
            [downLeft,  [-1, +1]],
            [left,      [-1,  0]],
        ];

        moves.forEach((item, _) => {
            for (let c = -3; c <= 3; c++) {
                for (let r = -3; r <= 3; r++) {
                    expect(
                        instance.exports.move(c, r, item[0])
                    ).toStrictEqual([c+item[1][0], r+item[1][1]]);
                }
            }
        });
    });
    test('ConwayLife', async () => {
        let map = null;
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                extGetCell: (c, r, _) => {
                    return map[r+1][c+1]
                },
            },
        });

        // Some random selected configurations
        const options = [
            // 0 -> 0
            [0, [
                [0,0,0],
                [0,0,0],
                [0,0,0],
            ]],
            [0, [
                [1,0,1],
                [0,0,0],
                [1,0,1],
            ]],
            [0, [
                [0,1,0],
                [1,0,1],
                [0,1,0],
            ]],
            [0, [
                [1,0,0],
                [0,0,0],
                [0,0,1],
            ]],
            [0, [
                [0,0,1],
                [0,0,0],
                [1,0,0],
            ]],
            [0, [
                [0,0,0],
                [1,0,1],
                [0,0,0],
            ]],
            [0, [
                [0,0,0],
                [0,0,1],
                [0,0,0],
            ]],
            // 0 -> 1
            [1, [
                [0,1,1],
                [0,0,1],
                [0,0,0],
            ]],
            // 1 -> 0
            [0, [
                [0,1,0],
                [1,0,1],
                [0,1,1],
            ]],
            [0, [
                [1,1,1],
                [1,0,1],
                [1,1,1],
            ]],
            [0, [
                [1,0,0],
                [1,1,0],
                [1,1,0],
            ]],
            [0, [
                [1,0,0],
                [0,1,0],
                [0,0,0],
            ]],
            [0, [
                [0,0,0],
                [0,1,1],
                [0,0,0],
            ]],
            [0, [
                [0,0,0],
                [0,1,0],
                [0,1,0],
            ]],
            // 1 -> 1
            [1, [
                [0,1,0],
                [0,1,0],
                [0,1,0],
            ]],
            [1, [
                [0,0,1],
                [0,1,0],
                [1,0,0],
            ]],
            [1, [
                [0,0,0],
                [0,1,0],
                [1,1,0],
            ]],
            [1, [
                [0,0,1],
                [0,1,0],
                [1,1,0],
            ]],
            [1, [
                [1,0,0],
                [1,1,0],
                [1,0,0],
            ]],
        ];

        for (let i = 0; i < options.length; i++) {
            map = options[i][1];
            expect(instance.exports.b3s23(0,0,0)).toBe(options[i][0]);
        }
    });

    test('GetCellPos', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                extGetCell: () => {},
            },
        });
        let cols = 11;
        let rows = 6;
        for (let offset = 0; offset < 100; offset++) {
            instance.exports.setStruct(offset, cols, rows, 0, 0);
            for (let c = 0; c < cols; c++) {
                for (let r = 0; r < rows; r++) {
                    expect(instance.exports.getCellPos(c, r, offset))
                        .toBe(offset+20+r*cols+c);
                }
            }
        }
    });

    test('GetSet', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                extGetCell: () => {},
            },
        });
        let cols = 11;
        let rows = 6;

        for (let offset = 0; offset < 314; offset += 7) {
            for (let fid = 0; fid < 2; fid ++){
                instance.exports.setStruct(offset, cols, rows, fid, 0);
                for (let c = 0; c < cols; c++) {
                    for (let r = 0; r < rows; r++) {
                        instance.exports.setCell(c, r, offset, 0, 5);
                        expect(instance.exports.getCell(c, r, offset)).toBe(5);
                        expect(new Uint8Array(instance.exports.mem.buffer)
                            [(fid*cols*rows)+offset+20+r*11+c]).toBe(5);
                    }
                }
            }
        }

        let offset = 314;
        instance.exports.setStruct(offset, cols, rows, 1, 0);

        // Out of bounds
        instance.exports.setCell(-7, 3, offset, 0, 5);
        expect(instance.exports.getCell(-7, 3, offset)).toBe(0);
        instance.exports.setCell(7, -3, offset, 0, 5);
        expect(instance.exports.getCell(7, -3, offset)).toBe(0);
        instance.exports.setCell(cols, 3, offset, 0, 5);
        expect(instance.exports.getCell(cols, 3, offset)).toBe(0);
        instance.exports.setCell(7, rows, offset, 0, 5);
        expect(instance.exports.getCell(7, rows, offset)).toBe(0);
    });

    test('ToChar', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                extGetCell: () => {},
            },
        });
        expect(String.fromCharCode(instance.exports.toChar(0))).toBe(" ");
        expect(String.fromCharCode(instance.exports.toChar(1))).toBe("+");
    });

    test('Render', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                extGetCell: () => {},
            },
        });

        const tostr = (v) => {
            return Buffer.from(v.buffer).toString();
        }

        let cols = 8;
        let rows = 6;
        let offset = 314;
        instance.exports.setStruct(offset, cols, rows, 1, 0);
        circle_pos.forEach((item, _) => {
            instance.exports.setCell(item[0], item[1], offset, 0, 1);
        });
        let [s, e] = instance.exports.render(offset);
        expect(tostr(new Uint8Array(instance.exports.mem.buffer).slice(s, e)))
            .toStrictEqual(circle);

        instance.exports.setStruct(offset, cols, rows, 0, 0);
        circle_pos.forEach((item, _) => {
            instance.exports.setCell(item[0], item[1], offset, 0, 1);
        });
        let [s1, e1] = instance.exports.render(offset);
        expect(tostr(new Uint8Array(instance.exports.mem.buffer).slice(s1, e1)))
            .toStrictEqual(circle);
    });

    test('Render', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname, {
            import: {
                extGetCell: () => {},
            },
        });

        const tostr = (v) => {
            return Buffer.from(v.buffer).toString();
        }

        let cols = oscilator.cols;
        let rows = oscilator.rows;
        let offset = 314;
        let rule = 2;
        instance.exports.setStruct(offset, cols, rows, 0, rule);
        oscilator.init.forEach((item, _) => {
            instance.exports.setCell(item[0], item[1], offset, 0, 1);
        });

        for (let s = 0; s < oscilator.after; s++) {
            instance.exports.step(offset);
        }

        let [s, e] = instance.exports.render(offset);
        expect(tostr(new Uint8Array(instance.exports.mem.buffer).slice(s, e)))
            .toStrictEqual(oscilator.result);

        for (let s = 0; s < oscilator.perod; s++) {
            instance.exports.step(offset);
        }
        [s, e] = instance.exports.render(offset);
        expect(tostr(new Uint8Array(instance.exports.mem.buffer).slice(s, e)))
            .toStrictEqual(oscilator.result);
    });
});
