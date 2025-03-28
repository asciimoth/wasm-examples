const loader = require('../loader');

describe('Conversion', () => {
    test('i64toi32', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        expect(instance.exports.i32wrapi64(BigInt(42))).toBe(42);
        expect(instance.exports.i32wrapi64(BigInt(-42))).toBe(-42);

        /*
            00000001 00000000 00000000 00000000 00000001 00000000 00000000 00000000
                                                00000001 00000000 00000000 00000000
        */
        expect(instance.exports.i32wrapi64(BigInt(0x0100000001000000))).toBe(0x1000000);
    });

    test('i32toi64', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        expect(instance.exports.i64extendi32u(42)).toBe(BigInt(42));
        expect(instance.exports.i64extendi32s(42)).toBe(BigInt(42));

        expect(instance.exports.i64extendi32u(-42)).toBe(BigInt(4294967254));
        expect(instance.exports.i64extendi32s(-42)).toBe(BigInt(-42));

        /*
                                                11111111 11111111 11111111 00000000
            00000000 00000000 00000000 00000000 11111111 11111111 11111111 00000000
        */
        expect(instance.exports.i64extendi32u(0xFFFFFF00)).toBe(BigInt(0x00000000FFFFFF00));
        /*
                                                11111111 11111111 11111111 00000000
            11111111 11111111 11111111 11111111 11111111 11111111 11111111 00000000
        */
        expect(instance.exports.i64extendi32s(0xFFFFFF00)).toBe(BigInt(-256));
    });

    test('IntExtension', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        /*
                              32         24         16         8
            Orig           00001100 | 00000011 | 00000011 | 11000011
            i32.extend8_s  11111111   11111111   11111111 | 11000011
            i32.extend16_s 00000000   00000000 | 00000011 | 11000011
        */
        expect(instance.exports.i32extend8s(201524163)).toBe(-61);
        expect(instance.exports.i32extend16s(201524163)).toBe(963);

        /*
                              64        56          48         40         32         24         16         8
            Orig           00110000 | 00110000 | 00110000 | 00110000 | 11001100 | 00000011 | 00000011 | 11000011
            i64.extend8_s  11111111   11111111   11111111   11111111   11111111   11111111   11111111 | 11000011
            i64.extend16_s 00000000   00000000   00000000   00000000   00000000   00000000 | 00000011 | 11000011
            i64.extend32_s 11111111   11111111   11111111   11111111 | 11001100 | 00000011 | 00000011 | 11000011
        */
        expect(instance.exports.i64extend8s(
            BigInt("0b0011000000110000001100000011000011001100000000110000001111000011")
        )).toBe(BigInt("-61"));
        expect(instance.exports.i64extend16s(
            BigInt("0b0011000000110000001100000011000011001100000000110000001111000011")
        )).toBe(BigInt("963"));
        expect(instance.exports.i64extend32s(
            BigInt("0b0011000000110000001100000011000011001100000000110000001111000011")
        )).toBe(BigInt("-872217661"));
    });

    test('Float2Float', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        expect(instance.exports.f64promotef32(42.0)).toBe(42.0);
        expect(instance.exports.f64promotef32(3.402823E+38)).toBe(3.4028230607370965e+38);


        expect(instance.exports.f32demotef64(42.0)).toBe(42.0);
        // Too big value
        expect(instance.exports.f32demotef64(1.7976931348623157e+308)).toBe(Infinity);
    });

    test('Float2IntTrunc', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        expect(instance.exports.i32truncf32s(42.0)).toBe(42);
        expect(instance.exports.i32truncf64s(42.0)).toBe(42);
        expect(instance.exports.i32truncf64s(42.69)).toBe(42);
        expect(instance.exports.i32truncf64s(-42.0)).toBe(-42);

        expect(instance.exports.i64truncf32s(42.0)).toBe(42n);
        expect(instance.exports.i64truncf64s(42.0)).toBe(42n);
        expect(instance.exports.i64truncf64s(42.69)).toBe(42n);
        expect(instance.exports.i64truncf64s(-42.0)).toBe(-42n);

        // Values out of the range, infinities and NaNs cause trap
        const err = "float unrepresentable in integer range"
        expect(() => { instance.exports.i32truncf64s(420000000000000000000.0) }).toThrow(err);
        expect(() => { instance.exports.i32truncf64u(-42.0) }).toThrow(err);
        expect(() => { instance.exports.i32truncf64s(Infinity) }).toThrow(err);
        expect(() => { instance.exports.i32truncf64s(NaN) }).toThrow(err);

        expect(() => { instance.exports.i64truncf64s(420000000000000000000.0) }).toThrow(err);
        expect(() => { instance.exports.i64truncf64u(-42.0) }).toThrow(err);
        expect(() => { instance.exports.i64truncf64s(Infinity) }).toThrow(err);
        expect(() => { instance.exports.i64truncf64s(NaN) }).toThrow(err);
    });

    test('Float2IntTruncSat', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        // Truncation with saturation do not trap if the value too big or too small
        // Instead value clamps to max/min available

        expect(instance.exports.i32truncsatf64s(420000000000000000000.0)).toBe(2147483647);
        expect(instance.exports.i32truncsatf64s(-420000000000000000000.0)).toBe(-2147483648);
        expect(instance.exports.i32truncsatf64s(Infinity)).toBe(2147483647);
        expect(instance.exports.i32truncsatf64s(-Infinity)).toBe(-2147483648);

        expect(instance.exports.i64truncsatf64s(420000000000000000000.0)).toBe(9223372036854775807n);
        expect(instance.exports.i64truncsatf64s(-420000000000000000000.0)).toBe(-9223372036854775808n);
        expect(instance.exports.i64truncsatf64s(Infinity)).toBe(9223372036854775807n);
        expect(instance.exports.i64truncsatf64s(-Infinity)).toBe(-9223372036854775808n);

        // +/- NaN becomes 0
        expect(instance.exports.i32truncsatf64s(NaN)).toBe(0);
        expect(instance.exports.i32truncsatf64s(-NaN)).toBe(0);

        expect(instance.exports.i64truncsatf64s(NaN)).toBe(0n);
        expect(instance.exports.i64truncsatf64s(-NaN)).toBe(0n);
    });

    test('Int2Float', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        expect(instance.exports.f32converti32s(42)).toBe(42.0);
        expect(instance.exports.f32converti32s(-42)).toBe(-42.0);
        expect(instance.exports.f32converti32u(-42)).toBe(4294967296.0);
        expect(instance.exports.f32converti32u(-1)).toBe(4294967296.0);

        expect(instance.exports.f64converti32s(42)).toBe(42.0);
        expect(instance.exports.f64converti32s(-42)).toBe(-42.0);
        expect(instance.exports.f64converti32s(2147483647)).toBe(2147483647.0);
        expect(instance.exports.f64converti32s(-2147483648)).toBe(-2147483648.0);

        // Precision loss
        expect(instance.exports.f32converti64s(BigInt("9223372036854775807"))).toBe(9223372036854776000.0);
    });

    test('Reinterpretation', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);

        expect(instance.exports.i32reinterpretf32(42.0)).toBe(1109917696);
        expect(instance.exports.f32reinterpreti32(1109917696)).toBe(42.0);

        expect(instance.exports.i64reinterpretf64(42.69)).toBe(4631204900687388344n);
        expect(instance.exports.f64reinterpreti64(4631204900687388344n)).toBe(42.69);
    });
});
