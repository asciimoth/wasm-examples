(module
  ;; Wasm type conversion operations follow the naming convention:
  ;;  result_type.operation_source_type
  ;; So if we a are converting type X to type Y using z conversion,
  ;;   it would be something like Y.z_X

  ;; Int <-> Int converson
  ;; =====================

  ;; Just drop away top half of i64 int without any cheks
  ;; Do not care about signed or not
  (func (export "i32wrapi64") (param i64) (result i32)
    (i32.wrap_i64 (local.get 0))
  )

  ;; Add 4 leading bytes filled with 0
  (func (export "i64extendi32u") (param i32) (result i64)
    (i64.extend_i32_u (local.get 0))
  )

  ;; Add 4 leading bytes filled with
  ;;   - 0 if param is positive
  ;;   - 1 if param is negative
  (func (export "i64extendi32s") (param i32) (result i64)
    (i64.extend_i32_s (local.get 0))
  )

  ;; Int extension 
  ;; =============
  ;; Extend lower bits while preserving sign (add bytes filed with 0 or 1)
  ;; These operations are among the few for which
  ;;   unsigned versions are not available.

  ;; Sign-extend i32's lower 8 bits to full 32 bits
  (func (export "i32extend8s") (param i32) (result i32)
    (i32.extend8_s (local.get 0))
  )
  ;; Sign-extend i32's lower 16 bits to full 32 bits
  (func (export "i32extend16s") (param i32) (result i32)
    (i32.extend16_s (local.get 0))
  )

  ;; Sign-extend i64's lower 8 bits to full 64 bits
  (func (export "i64extend8s") (param i64) (result i64)
    (i64.extend8_s (local.get 0))
  )
  ;; Sign-extend i64's lower 16 bits to full 64 bits
  (func (export "i64extend16s") (param i64) (result i64)
    (i64.extend16_s (local.get 0))
  )
  ;; Sign-extend i64's lower 32 bits to full 64 bits
  (func (export "i64extend32s") (param i64) (result i64)
    (i64.extend32_s (local.get 0))
  )

  ;; Float <-> Float conversion
  ;; ==========================

  ;; Promote f32 to f64
  ;; No loss of precision
  (func (export "f64promotef32") (param f32) (result f64)
    (f64.promote_f32 (local.get 0))
  )

  ;; Demote f64 to f32
  ;; Too big value become Inf
  (func (export "f32demotef64") (param f64) (result f32)
    (f32.demote_f64 (local.get 0))
  )

  ;; Float -> Int truncation
  ;; =======================
  ;; Traps if param value out of range of result type or it is NaN

  ;; Truncate f64 to signed i32
  (func (export "i32truncf64s") (param f64) (result i32)
    (i32.trunc_f64_s (local.get 0))
  )

  ;; Truncate f32 to signed i32
  (func (export "i32truncf32s") (param f32) (result i32)
    (i32.trunc_f32_s (local.get 0))
  )

  ;; Truncate f32 to unsigned i32
  (func (export "i32truncf32u") (param f32) (result i32)
    (i32.trunc_f32_u (local.get 0))
  )

  ;; Truncate f64 to unsigned i32
  (func (export "i32truncf64u") (param f64) (result i32)
    (i32.trunc_f64_u (local.get 0))
  )

  ;; Truncate f32 to signed i64
  (func (export "i64truncf32s") (param f32) (result i64)
    (i64.trunc_f32_s (local.get 0))
  )

  ;; Truncate f32 to unsigned i64
  (func (export "i64truncf32u") (param f32) (result i64)
    (i64.trunc_f32_u (local.get 0))
  )

  ;; Truncate f64 to signed i64
  (func (export "i64truncf64s") (param f64) (result i64)
    (i64.trunc_f64_s (local.get 0))
  )

  ;; Truncate f64 to unsigned i64
  (func (export "i64truncf64u") (param f64) (result i64)
    (i64.trunc_f64_u (local.get 0))
  )

  ;; Int truncation with saturation
  ;; ==============================
  ;; These ops clamp out-of-range values to min/max instead of trapping

  (func (export "i32truncsatf64s") (param f64) (result i32)
    (i32.trunc_sat_f64_s (local.get 0))
  )
  (func (export "i32truncsatf64u") (param f64) (result i32)
    (i32.trunc_sat_f64_u (local.get 0))
  )
  (func (export "i32truncsatf32s") (param f32) (result i32)
    (i32.trunc_sat_f32_s (local.get 0))
  )
  (func (export "i32truncsatf32u") (param f32) (result i32)
    (i32.trunc_sat_f32_u (local.get 0))
  )

  (func (export "i64truncsatf64s") (param f64) (result i64)
    (i64.trunc_sat_f64_s (local.get 0))
  )
  (func (export "i64truncsatf64u") (param f64) (result i64)
    (i64.trunc_sat_f64_u (local.get 0))
  )
  (func (export "i64truncsatf32s") (param f32) (result i64)
    (i64.trunc_sat_f32_s (local.get 0))
  )
  (func (export "i64truncsatf32u") (param f32) (result i64)
    (i64.trunc_sat_f32_u (local.get 0))
  )

  ;; Int -> Float conversion
  ;; =======================

  ;; Convert signed i32 to f32
  ;; Exact where possible
  (func (export "f32converti32s") (param i32) (result f32)
    (f32.convert_i32_s (local.get 0))
  )

  ;; Convert unsigned i32 to f32
  (func (export "f32converti32u") (param i32) (result f32)
    (f32.convert_i32_u (local.get 0))
  )

  ;; Convert signed i64 to f32
  ;; May lose precision for large valuess
  (func (export "f32converti64s") (param i64) (result f32)
    (f32.convert_i64_s (local.get 0))
  )

  ;; Convert unsigned i64 to f32
  ;; May lose precision for large values
  (func (export "f32converti64u") (param i64) (result f32)
    (f32.convert_i64_u (local.get 0))
  )

  ;; Convert signed i32 to f64
  ;; Exact conversion
  (func (export "f64converti32s") (param i32) (result f64)
    (f64.convert_i32_s (local.get 0))
  )

  ;; Convert unsigned i32 to f64
  ;; Exact conversion
  (func (export "f64converti32u") (param i32) (result f64)
    (f64.convert_i32_u (local.get 0))
  )

  ;; Convert signed i64 to f64
  ;; Preserves 53 bits of precision
  (func (export "f64converti64s") (param i64) (result f64)
    (f64.convert_i64_s (local.get 0))
  )

  ;; Convert unsigned i64 to f64
  ;; Preserves 53 bits of precision
  (func (export "f64converti64u") (param i64) (result f64)
    (f64.convert_i64_u (local.get 0)) ;; Bit Reinterpretation
  )

  ;; Bit reinterpretation
  ;; ====================
  ;; Change type "label" of value
  ;; Leave exactly same raw bits ontop of stack without any conversions

  ;; Reinterpret f32's bits as i32
  (func (export "i32reinterpretf32") (param f32) (result i32)
    (i32.reinterpret_f32 (local.get 0))
  )
  ;; Reinterpret i32's bits as f32
  (func (export "f32reinterpreti32") (param i32) (result f32)
    (f32.reinterpret_i32 (local.get 0))
  )

  ;; Reinterpret f64's bits as i64
  (func (export "i64reinterpretf64") (param f64) (result i64)
    (i64.reinterpret_f64 (local.get 0))
  )
  ;; Reinterpret i64's bits as f64
  (func (export "f64reinterpreti64") (param i64) (result f64)
    (f64.reinterpret_i64 (local.get 0))
  )
)
