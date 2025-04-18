const loader = require('../loader');

const XorShiftRef = [
    42,
    11355432,
    -1458948948,
    476557059,
    -646921280,
    -534983740,
    1441438134,
    -581500456,
    -1863322962,
    -1174750317,
    1067267639,
    -1305949734,
    -915909069,
    -1234916508,
    1108305632,
    1958019241,
    1084823001,
    542285520,
    43795860,
    -805400349,
    -1581433774,
    -1059547543,
    -1867631869,
    -1895729948,
    -1842798230,
    1988327272,
    362877119,
    -1049917468,
    -2088977713,
    -1869657219,
    1174021677,
    651120882,
    1459594714,
    -355324936,
    1510144494,
];

describe('Random', () => {
    test('XorShift', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        let result = [XorShiftRef[0]];
        for (let i = 1; i < XorShiftRef.length; i++) {
            result.push(instance.exports.xor32(result[i-1]));
        }
        expect(result).toStrictEqual(XorShiftRef);
    });
});
