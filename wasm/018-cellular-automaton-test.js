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

const tostr = (v) => {
    return Buffer.from(v.buffer).toString();
}

describe('CA', () => {
    test('init', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        instance.exports.init(7, 11, 0, 2);
        expect(instance.exports.vCols.value).toBe(7);
        expect(instance.exports.vRows.value).toBe(11);
        expect(instance.exports.vFrameSize.value).toBe(77);
        expect(instance.exports.vFrame.value).toBe(0);
        expect(instance.exports.vOutput.value).toBe(77*2);
        expect(instance.exports.vRule.value).toBe(0);
        expect(instance.exports.vNeighbourhood.value).toBe(2);
    });
    test('switch', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        instance.exports.init(7, 11, 0, 2);
        expect(instance.exports.vFrame.value).toBe(0);
        expect(instance.exports.anotherFrame()).toBe(77);
        instance.exports.swapFrames();
        expect(instance.exports.vFrame.value).toBe(77);
        expect(instance.exports.anotherFrame()).toBe(0);
    });
    test('OOB', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        instance.exports.init(7, 11, 0, 2);
        expect(instance.exports.checkOOB(0,0)).toBe(0);
        expect(instance.exports.checkOOB(6,10)).toBe(0);
        expect(instance.exports.checkOOB(7,0)).toBe(1);
        expect(instance.exports.checkOOB(0,11)).toBe(1);
        expect(instance.exports.checkOOB(7,11)).toBe(1);
    });
    test('cell', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        instance.exports.init(7, 11, 0, 2);
        let frame = instance.exports.vFrame.value;
        expect(instance.exports.getCell(0,0,frame)).toBe(0);
        instance.exports.setCell(0,0,1,frame);
        expect(instance.exports.getCell(0,0,frame)).toBe(1);
        expect(instance.exports.getCell(6,10,frame)).toBe(0);
        instance.exports.setCell(6,10,1,frame);
        expect(instance.exports.getCell(6,10,frame)).toBe(1);
        instance.exports.swapFrames();
        frame = instance.exports.vFrame.value;
        expect(instance.exports.getCell(0,0,frame)).toBe(0);
        expect(instance.exports.getCell(6,10,frame)).toBe(0);
        instance.exports.swapFrames();
        frame = instance.exports.vFrame.value;
        expect(instance.exports.getCell(0,0,frame)).toBe(1);
        expect(instance.exports.getCell(6,10,frame)).toBe(1);
    });
    test('b3s23', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        const variants = [
            [0,0,0],
            [0,1,0],
            [0,2,0],
            [0,3,1],
            [0,4,0],
            [0,5,0],
            [0,6,0],
            [0,7,0],
            [0,8,0],
            [1,0,0],
            [1,2,1],
            [1,3,1],
            [1,4,0],
            [1,5,0],
            [1,6,0],
            [1,7,0],
            [1,8,0],
        ];
        for (let i = 0; i < variants.length; i++) {
            let v = variants[i];
            expect(instance.exports.b3s23(v[0], v[1])).toBe(v[2]);
        }
    });
    test('b1s012345678', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        const variants = [
            [0,0,0],
            [0,1,1],
            [0,2,0],
            [0,3,0],
            [0,4,0],
            [0,5,0],
            [0,6,0],
            [0,7,0],
            [0,8,0],
            [1,0,1],
            [1,1,1],
            [1,2,1],
            [1,3,1],
            [1,4,1],
            [1,5,1],
            [1,6,1],
            [1,7,1],
            [1,8,1],
        ];
        for (let i = 0; i < variants.length; i++) {
            let v = variants[i];
            expect(instance.exports.b1s012345678(v[0], v[1])).toBe(v[2]);
        }
    });
    test('Moore', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        let variants = [
            [0, [0,0,0,0,0,0,0,0]],
            [8, [1,1,1,1,1,1,1,1]],
        ];
        for (let i = 0; i < 8; i++) {
            let a = [1, [0,0,0,0,0,0,0,0]]
            a[1][i] = 1;
            variants.push(a)
        }
        for (let i = 0; i < variants.length; i++) {
            let r = variants[i][0];
            let n = variants[i][1];
            expect(instance.exports.Moore(
                n[0],n[1],n[2],n[3],n[4],n[5],n[6],n[7])).toBe(r);
        }
    });
    test('VonNeumann', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        let variants = [
            [0, [0,0,0,0,0,0,0,0]],
            [4, [1,1,1,1,1,1,1,1]],
            [4, [0,1,0,1,0,1,0,1]],
            [0, [1,0,1,0,1,0,1,0]],
        ];
        for (let i = 1; i < 8; i+=2) {
            let a = [1, [0,0,0,0,0,0,0,0]]
            a[1][i] = 1;
            variants.push(a)
        }
        for (let i = 0; i < 8; i+=2) {
            let a = [0, [0,0,0,0,0,0,0,0]]
            a[1][i] = 1;
            variants.push(a)
        }
        for (let i = 0; i < variants.length; i++) {
            let r = variants[i][0];
            let n = variants[i][1];
            expect(instance.exports.VonNeumann(
                n[0],n[1],n[2],n[3],n[4],n[5],n[6],n[7])).toBe(r);
        }
    });
    test('toChar', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        expect(instance.exports.toChar(0)).toBe(32);
        expect(instance.exports.toChar(1)).toBe(43);
    });

    test('Render', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        instance.exports.init(8, 6, 0, 2);
        for (let i = 0; i < circle_pos.length; i++) {
            let c = circle_pos[i][0];
            let r = circle_pos[i][1];
            instance.exports.setCell(c,r,1,instance.exports.vFrame);
        }
        let [s, e] = instance.exports.render();
        expect(tostr(new Uint8Array(instance.exports.memory.buffer)
            .slice(s, e)))
            .toStrictEqual(circle);
    });

    test('Simulation', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        instance.exports.init(oscilator.cols, oscilator.rows, 0, 2);
        for (let i = 0; i < oscilator.init.length; i++) {
            let c = oscilator.init[i][0];
            let r = oscilator.init[i][1];
            instance.exports.setCell(c,r,1,instance.exports.vFrame);
        }
        for (let s = 0; s < oscilator.after; s++) {
            instance.exports.step();
        }
        let [s, e] = instance.exports.render();
        expect(tostr(new Uint8Array(instance.exports.memory.buffer)
            .slice(s, e)))
            .toStrictEqual(oscilator.result);
        for (let s = 0; s < oscilator.perod; s++) {
            instance.exports.step();
        }
        [s, e] = instance.exports.render();
        expect(tostr(new Uint8Array(instance.exports.memory.buffer)
            .slice(s, e)))
            .toStrictEqual(oscilator.result);
    });
});
