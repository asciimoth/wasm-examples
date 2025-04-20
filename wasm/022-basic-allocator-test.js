const loader = require('../loader');

const page = 65536;

function load32(array, offset) {
    return array[offset] + 
           (array[offset + 1] << 8) + 
           (array[offset + 2] << 16) + 
           (array[offset + 3] << 24);
}

const dumpAllocatorStructure = (memory, pointer) => {
    const mem = new Uint8Array(memory.buffer);
    alloc = {};
    alloc.begin = pointer;
    alloc.end = load32(mem, pointer)
    alloc.segments = [];
    let segment = pointer+4;
    while (true) {
        let begin = segment;
        let next = load32(mem, begin+1);
        let status = mem[begin];
        if (status == 0) {
            status = "free";
        } else {
            status = "in use"
        }
        alloc.segments.push({
            begin: begin,
            next: next,
            status: status,
        });
        if (next < alloc.end) {
            segment = next;
        } else { break }
    }
    return alloc
}

describe('Basic allocator', () => {
    test('FitMemSize', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        expect(instance.exports.fitMemSize(0)).toBe(1);
        expect(instance.exports.fitMemSize(1)).toBe(1);
        expect(instance.exports.fitMemSize(42)).toBe(1);
        expect(instance.exports.fitMemSize(1024)).toBe(1);
        expect(new Uint8Array(instance.exports.memory.buffer).length)
            .toBe(page);
        expect(instance.exports.fitMemSize(page)).toBe(1);
        expect(new Uint8Array(instance.exports.memory.buffer).length)
            .toBe(page);
        expect(instance.exports.fitMemSize(page+1)).toBe(1);
        expect(new Uint8Array(instance.exports.memory.buffer).length)
            .toBe(page*2);
        expect(instance.exports.fitMemSize(page*3.5)).toBe(2);
        expect(new Uint8Array(instance.exports.memory.buffer).length)
            .toBe(page*4);
    });
    test('Allocator structure', async () => {
        const { instance } = await loader.loadwasm(__filename, __dirname);
        const begin = page*2;
        const end = page*3;
        expect(instance.exports.init(begin, end)).toBe(begin);
        expect(
            dumpAllocatorStructure(instance.exports.memory, begin)
        ).toStrictEqual({
            begin: begin,
            end: end,
            segments: [
                {
                    begin: begin+4,
                    next: end,
                    status: "free",
                },
            ],
        });
        expect(instance.exports.isLastSegment(begin, begin+4)).toBe(1);
        expect(instance.exports.splitSegmentIfNeeded(begin+4, 100)).toBe(1);
        instance.exports.markSegmentUsed(begin+109);
        expect(
            dumpAllocatorStructure(instance.exports.memory, begin)
        ).toStrictEqual({
            begin: begin,
            end: end,
            segments: [
                {
                    begin: begin+4,
                    next: begin+109,
                    status: "free",
                },
                {
                    begin: begin+109,
                    next: end,
                    status: "in use",
                },
            ],
        });
        expect(instance.exports.getSegmentSize(begin+4)).toBe(100);
        expect(instance.exports.getSegmentSize(begin+109)).toBe(
            end-begin-109-5
        );
        instance.exports.markSegmentFree(begin+109);
        expect(instance.exports.splitSegmentIfNeeded(begin+4, 0)).toBe(1);
        expect(instance.exports.splitSegmentIfNeeded(begin+4, 0)).toBe(1);
        expect(instance.exports.splitSegmentIfNeeded(begin+4, 0)).toBe(1);
        expect(instance.exports.splitSegmentIfNeeded(begin+4, 1)).toBe(0);
        instance.exports.markSegmentUsed(begin+4);
        expect(instance.exports.splitSegmentIfNeeded(begin+4, 0)).toBe(0);
        expect(instance.exports.splitSegmentIfNeeded(begin+9, 3)).toBe(1);
        expect(instance.exports.splitSegmentIfNeeded(begin+9, 1)).toBe(1);
        expect(instance.exports.splitSegmentIfNeeded(begin+109, page)).toBe(0);
        expect(
            dumpAllocatorStructure(instance.exports.memory, begin)
        ).toStrictEqual({
            begin: begin,
            end: end,
            segments: [
                {
                    begin: begin+4,
                    next: begin+9,
                    status: "in use",
                },
                {
                    begin: begin+9,
                    next: begin+17,
                    status: "free",
                },
                {
                    begin: begin+17,
                    next: begin+109,
                    status: "free",
                },
                {
                    begin: begin+109,
                    next: end,
                    status: "free",
                },
            ],
        });
        instance.exports.joinSegments(begin, begin+17)
        instance.exports.joinSegments(begin, begin+9)
        instance.exports.joinSegments(begin, begin+4)
        expect(
            dumpAllocatorStructure(instance.exports.memory, begin)
        ).toStrictEqual({
            begin: begin,
            end: end,
            segments: [
                {
                    begin: begin+4,
                    next: begin+9,
                    status: "in use",
                },
                {
                    begin: begin+9,
                    next: end,
                    status: "free",
                },
            ],
        });
        instance.exports.markSegmentFree(begin+4);
        instance.exports.joinSegments(begin, begin+4)
        expect(
            dumpAllocatorStructure(instance.exports.memory, begin)
        ).toStrictEqual({
            begin: begin,
            end: end,
            segments: [
                {
                    begin: begin+4,
                    next: begin+9,
                    next: end,
                    status: "free",
                },
            ],
        })
    });
});
