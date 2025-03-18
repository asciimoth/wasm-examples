const loader = require('../loader');

describe('Biwise', () => {
  test('And', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);
    /*
      A | B |A and B
      0 | 0 |   0
      0 | 1 |   0
      1 | 0 |   0
      1 | 1 |   1
    */

    /*
      Numbers in wasm are little-endian.
      We'll talk about it more in future examples

      00000110 00000000 00000000 00000000
                      and
      00001011 00000000 00000000 00000000
                       =
      00000010 00000000 00000000 00000000
    */
    expect(instance.exports.andi32(6, 11)).toBe(2);

    /*
      00001000 00000000 00000000 00000000
                      and
      00010000 00000000 00000000 00000000
                       =
      00000000 00000000 00000000 00000000
    */
    expect(instance.exports.andi32(8, 16)).toBe(0);
    // Order dont matter for and operation
    expect(instance.exports.andi32(16, 8)).toBe(0);

    // X and 0 = 0
    expect(instance.exports.andi32(1, 0)).toBe(0);
    expect(instance.exports.andi32(2, 0)).toBe(0);
    expect(instance.exports.andi32(137, 0)).toBe(0);

    // X and X = X
    expect(instance.exports.andi32(1, 1)).toBe(1);
    expect(instance.exports.andi32(-1, -1)).toBe(-1);
    expect(instance.exports.andi32(42, 42)).toBe(42);

    /*
      Check this if you feel confused about binary representation
        of negative numbers:
      https://courses.cs.washington.edu/courses/cse390b/21sp/readings/negative_binary.html

      00000010 00000000 00000000 00000000
                      and
      11111110 11111111 11111111 11111111
                       =
      00000010 00000000 00000000 00000000
    */
    expect(instance.exports.andi32(2, -2)).toBe(2);
  });

  test('Or', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);
    /*
      A | B |A or B
      0 | 0 |  0
      0 | 1 |  1
      1 | 0 |  1
      1 | 1 |  1
    */

    /*
      00000110 00000000 00000000 00000000
                      or
      00001011 00000000 00000000 00000000
                       =
      00001111 00000000 00000000 00000000
    */
    expect(instance.exports.ori32(6, 11)).toBe(15);

    /*
      00001000 00000000 00000000 00000000
                      or
      00010000 00000000 00000000 00000000
                       =
      00011000 00000000 00000000 00000000
    */
    expect(instance.exports.ori32(8, 16)).toBe(24);
    // Order no mater again
    expect(instance.exports.ori32(16, 8)).toBe(24);

    // X or 0 = X
    expect(instance.exports.ori32(1, 0)).toBe(1);
    expect(instance.exports.ori32(2, 0)).toBe(2);
    expect(instance.exports.ori32(137, 0)).toBe(137);

    // X or X = X also
    expect(instance.exports.ori32(1, 1)).toBe(1);
    expect(instance.exports.ori32(-1, -1)).toBe(-1);
    expect(instance.exports.ori32(42, 42)).toBe(42);

    /*
      00000010 00000000 00000000 00000000
                      or
      11111110 11111111 11111111 11111111
                       =
      11111110 11111111 11111111 11111111
    */
    expect(instance.exports.ori32(2, -2)).toBe(-2);
  });

  test('Xor', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);
    /*
      A | B |A xor B
      0 | 0 |   0
      0 | 1 |   1
      1 | 0 |   1
      1 | 1 |   0
    */

    /*
      00000110 00000000 00000000 00000000
                      xor
      00001011 00000000 00000000 00000000
                       =
      00001101 00000000 00000000 00000000
    */
    expect(instance.exports.xori32(6, 11)).toBe(13);

    /*
      00001000 00000000 00000000 00000000
                      xor
      00010000 00000000 00000000 00000000
                       =
      00011000 00000000 00000000 00000000
    */
    expect(instance.exports.xori32(8, 16)).toBe(24);
    // Order no mater again
    expect(instance.exports.xori32(16, 8)).toBe(24);

    /*
      Xor operation is also reversible.
      If you do it any even number of times it gets same result
      And if you do it any odd number of times it gets (another) same result

      A xor B = C
      A xor B xor B = A
      A xor B xor B xor B = C
      A xor B xor B xor B xor B = A
      ... etc
    */ 
    expect(instance.exports.xori32(6, 11)).toBe(13);
    expect(instance.exports.xori32(6, instance.exports.xori32(6, 11))).toBe(11);
    expect(instance.exports.xori32(6, instance.exports.xori32(6, instance.exports.xori32(6, 11)))).toBe(13);
    expect(instance.exports.xori32(6, instance.exports.xori32(6, instance.exports.xori32(6, instance.exports.xori32(6, 11))))).toBe(11);

    /*
      00000010 00000000 00000000 00000000
                      or
      11111110 11111111 11111111 11111111
                       =
      11111100 11111111 11111111 11111111
    */
    expect(instance.exports.xori32(2, -2)).toBe(-4);
  });

  test('Shift left', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);

    /*
      When you "shifting left" number, all it bits move to next position
      in the direction of the MORE significant.

      It may be really confusig in little-endian representation so here is
      example in more familiar to humans big-endian format:
      00100000 00000000 00000000 00000001
                    lsh (<-)
      01000000 00000000 00000000 00000010
                    lsh (<-)
      10000000 00000000 00000000 00000100
                    lsh (<-)
      00000000 00000000 00000000 00001000

      And same in little-endian representation:
      00000001 00000000 00000000 00100000
                      lsh
      00000010 00000000 00000000 01000000
                      lsh
      00000100 00000000 00000000 10000000
                      lsh
      00001000 00000000 00000000 00000000

      Note that righter bit in most significant byte become lost after left shift
    */

    // You may note that left shifting and multiplication per 2 is a same thing
    expect(instance.exports.shli32(1, 1)).toBe(2);
    expect(instance.exports.shli32(1, 2)).toBe(4);
    expect(instance.exports.shli32(1, instance.exports.shli32(1, 1))).toBe(4);

    expect(instance.exports.shli32(7, 1)).toBe(14); // 7 * 2
    expect(instance.exports.shli32(7, 2)).toBe(28); // 7 * (2*2)
    expect(instance.exports.shli32(7, 3)).toBe(56); // 7 * (2*3)

    // Left shift independent from integer sign (unlike right shift)
    expect(instance.exports.shli32(3, 2)).toBe(12);
    expect(instance.exports.shli32(-3, 2)).toBe(-12);
  });

  test('Shift right', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);
    /*
      When you "shifting left" number, all it bits move to next position
      in the direction of the LESS significant.
      So it's like division by two with losing modulo
    */
    expect(instance.exports.shrui32(4, 1)).toBe(2);
    expect(instance.exports.shrui32(4, 2)).toBe(1);
    expect(instance.exports.shrui32(5, 1)).toBe(2);
    expect(instance.exports.shrui32(5, 2)).toBe(1);

    /*
      But what if we shift right a negative number:
      ( big endian format for your comfort)
       11111111 11111111 11111111 11111100
                     rsh (->)
       01111111 11111111 11111111 11111110
    */
    expect(instance.exports.shrui32(-4, 1)).toBe(2147483646);
    /*
      Looks weird. Thats because right shift should be done different for
      signed and unsigned numbers.
      If we are shifting unsigned number, we are just moving all bits and adding
      leading zero bit.
      But if we are shifting signed one, we shoud chek if it is positive or
      negative and add leading 0 or 1 respectively.
      So wasm has two operations: shr_u and shr_s.
    */

    // And since JS use signed ints always, we should use shr_s variant:
    expect(instance.exports.shrsi32(4, 1)).toBe(2);
    expect(instance.exports.shrsi32(-4, 1)).toBe(-2);

    // Also you may note that shr_u works nice for our signed integers
    //   till they are positive.
  });

  test('Rotate', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);
    /*
      Rotation is like shifting but all bits moved beyond the edge, appears
      from the opposite one:
      (yeat agein big endian format)
      10100000 00000000 00000000 00000101
                    rotl <<
      01000000 00000000 00000000 00001011
                    rotl <<
      10000000 00000000 00000000 00010110
                    rotl <<
      00000000 00000000 00000000 00101101

      10100000 00000000 00000000 00000101
                    rotr >>
      11010000 00000000 00000000 00000010
                    rotr >>
      01101000 00000000 00000000 00000001
                    rotr >>
      10110100 00000000 00000000 00000000
    */
    expect(instance.exports.rotli32(-1610612731, 1)).toBe(1073741835);
    expect(instance.exports.rotli32(1073741835, 1)).toBe(-2147483626);
    expect(instance.exports.rotli32(-2147483626, 1)).toBe(45);

    expect(instance.exports.rotri32(-1610612731, 1)).toBe(-805306366);
    expect(instance.exports.rotri32(-805306366, 1)).toBe(1744830465);
    expect(instance.exports.rotri32(1744830465, 1)).toBe(-1275068416);

  });

  test('Count zeros', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);
    /*
      Clz (count leading zeros) and ctz (count traling zeros) operations
      count zero bits at the begining and end of integer:
      (big endian)
      00000000 00000010 00000001 00000000
      \_____________/            \______/
          clz = 14               ctz = 8
    */
    expect(instance.exports.clzi32(131328)).toBe(14);
    expect(instance.exports.ctzi32(131328)).toBe(8);
  });

  test('Pops count', async () => {
    const { instance } = await loader.loadwasm(__filename, __dirname);
    /*
      Popcnt operation count raised (1) bits in integer:
      00100010 00000010 00000001 00000001
        +   +        +         +        +  => 5
    */
    expect(instance.exports.popcnti32(570556673)).toBe(5);
  });

  /*
    You may be interested why there is no builtin bitwise not operation.
    Thats because you can implement bitwise inversion using xor.
    Cause xoring bit with 1 return this bit inverted.

    0     1   1
    1     1   0
    0     1   1
    1 xor 1 = 0
    1     1   0
    0     1   1
    0     1   1
    0     1   1
  */
});
