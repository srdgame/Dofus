﻿package com.hurlant.math
{
    import flash.utils.ByteArray;
    import com.hurlant.util.Hex;
    import com.hurlant.crypto.prng.Random;
    import com.hurlant.util.Memory;
    import com.hurlant.math.bi_internal; 

    use namespace bi_internal;

    public class BigInteger 
    {

        public static const DB:int = 30;
        public static const DV:int = (1 << DB);
        public static const DM:int = (DV - 1);
        public static const BI_FP:int = 52;
        public static const FV:Number = Math.pow(2, BI_FP);
        public static const F1:int = (BI_FP - DB);//22
        public static const F2:int = ((2 * DB) - BI_FP);//8
        public static const ZERO:BigInteger = nbv(0);
        public static const ONE:BigInteger = nbv(1);
        public static const lowprimes:Array = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 0x0101, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509];
        public static const lplim:int = ((1 << 26) / lowprimes[(lowprimes.length - 1)]);

        public var t:int;
        bi_internal var s:int;
        bi_internal var a:Array;

        public function BigInteger(value:*=null, radix:int=0, unsigned:Boolean=false)
        {
            var array:ByteArray;
            var length:int;
            super();
            this.a = new Array();
            if ((value is String))
            {
                if (((radix) && (!((radix == 16)))))
                {
                    throw (new Error("BigInteger construction with radix!=16 is not supported."));
                };
                value = Hex.toArray(value);
                radix = 0;
            };
            if ((value is ByteArray))
            {
                array = (value as ByteArray);
                length = ((radix) || ((array.length - array.position)));
                this.fromArray(array, length, unsigned);
            };
        }

        public static function nbv(value:int):BigInteger
        {
            var bn:BigInteger = new (BigInteger)();
            bn.fromInt(value);
            return (bn);
        }


        public function dispose():void
        {
            var r:Random = new Random();
            var i:uint;
            while (i < this.a.length)
            {
                this.a[i] = r.nextByte();
                delete this.a[i];
                i++;
            };
            this.a = null;
            this.t = 0;
            this.s = 0;
            Memory.gc();
        }

        public function toString(radix:Number=16):String
        {
            var k:int;
            if (this.s < 0)
            {
                return (("-" + this.negate().toString(radix)));
            };
            switch (radix)
            {
                case 2:
                    k = 1;
                    break;
                case 4:
                    k = 2;
                    break;
                case 8:
                    k = 3;
                    break;
                case 16:
                    k = 4;
                    break;
                case 32:
                    k = 5;
                    break;
            };
            var km:int = ((1 << k) - 1);
            var d:int;
            var m:Boolean;
            var r:String = "";
            var i:int = this.t;
            var p:int = (DB - ((i * DB) % k));
            if (i-- > 0)
            {
                if ((((p < DB)) && (((d = (this.a[i] >> p)) > 0))))
                {
                    m = true;
                    r = d.toString(36);
                };
                while (i >= 0)
                {
                    if (p < k)
                    {
                        d = ((this.a[i] & ((1 << p) - 1)) << (k - p));
                        var _temp_1 = d;
                        p = (p + (DB - k));
                        d = (_temp_1 | (this.a[--i] >> p));
                    }
                    else
                    {
                        p = (p - k);
                        d = ((this.a[i] >> p) & km);
                        if (p <= 0)
                        {
                            p = (p + DB);
                            i--;
                        };
                    };
                    if (d > 0)
                    {
                        m = true;
                    };
                    if (m)
                    {
                        r = (r + d.toString(36));
                    };
                };
            };
            return (((m) ? r : "0"));
        }

        public function toArray(array:ByteArray):uint
        {
            var k:int = 8;
            var km:int = ((1 << 8) - 1);
            var d:int;
            var i:int = this.t;
            var p:int = (DB - ((i * DB) % k));
            var m:Boolean;
            var c:int;
            if (i-- > 0)
            {
                if ((((p < DB)) && (((d = (this.a[i] >> p)) > 0))))
                {
                    m = true;
                    array.writeByte(d);
                    c++;
                };
                while (i >= 0)
                {
                    if (p < k)
                    {
                        d = ((this.a[i] & ((1 << p) - 1)) << (k - p));
                        var _temp_1 = d;
                        p = (p + (DB - k));
                        d = (_temp_1 | (this.a[--i] >> p));
                    }
                    else
                    {
                        p = (p - k);
                        d = ((this.a[i] >> p) & km);
                        if (p <= 0)
                        {
                            p = (p + DB);
                            i--;
                        };
                    };
                    if (d > 0)
                    {
                        m = true;
                    };
                    if (m)
                    {
                        array.writeByte(d);
                        c++;
                    };
                };
            };
            return (c);
        }

        public function valueOf():Number
        {
            if (this.s == -1)
            {
                return (-(this.negate().valueOf()));
            };
            var coef:Number = 1;
            var value:Number = 0;
            var i:uint;
            while (i < this.t)
            {
                value = (value + (this.a[i] * coef));
                coef = (coef * DV);
                i++;
            };
            return (value);
        }

        public function negate():BigInteger
        {
            var r:BigInteger = this.nbi();
            ZERO.subTo(this, r);
            return (r);
        }

        public function abs():BigInteger
        {
            return ((((this.s)<0) ? this.negate() : this));
        }

        public function compareTo(v:BigInteger):int
        {
            var r:int = (this.s - v.s);
            if (r != 0)
            {
                return (r);
            };
            var i:int = this.t;
            r = (i - v.t);
            if (r != 0)
            {
                return (r);
            };
            while (--i >= 0)
            {
                r = (this.a[i] - v.a[i]);
                if (r != 0)
                {
                    return (r);
                };
            };
            return (0);
        }

        bi_internal function nbits(x:int):int
        {
            var t:int;
            var r:int = 1;
            t = (x >>> 16);
            if (t != 0)
            {
                x = t;
                r = (r + 16);
            };
            t = (x >> 8);
            if (t != 0)
            {
                x = t;
                r = (r + 8);
            };
            t = (x >> 4);
            if (t != 0)
            {
                x = t;
                r = (r + 4);
            };
            t = (x >> 2);
            if (t != 0)
            {
                x = t;
                r = (r + 2);
            };
            t = (x >> 1);
            if (t != 0)
            {
                x = t;
                r = (r + 1);
            };
            return (r);
        }

        public function bitLength():int
        {
            if (this.t <= 0)
            {
                return (0);
            };
            return (((DB * (this.t - 1)) + this.nbits((this.a[(this.t - 1)] ^ (this.s & DM)))));
        }

        public function mod(v:BigInteger):BigInteger
        {
            var r:BigInteger = this.nbi();
            this.abs().divRemTo(v, null, r);
            if ((((this.s < 0)) && ((r.compareTo(ZERO) > 0))))
            {
                v.subTo(r, r);
            };
            return (r);
        }

        public function modPowInt(e:int, m:BigInteger):BigInteger
        {
            var z:IReduction;
            if ((((e < 0x0100)) || (m.isEven())))
            {
                z = new ClassicReduction(m);
            }
            else
            {
                z = new MontgomeryReduction(m);
            };
            return (this.exp(e, z));
        }

        bi_internal function copyTo(r:BigInteger):void
        {
            var i:int = (this.t - 1);
            while (i >= 0)
            {
                r.a[i] = this.a[i];
                i--;
            };
            r.t = this.t;
            r.s = this.s;
        }

        bi_internal function fromInt(value:int):void
        {
            this.t = 1;
            this.s = (((value)<0) ? -1 : 0);
            if (value > 0)
            {
                this.a[0] = value;
            }
            else
            {
                if (value < -1)
                {
                    this.a[0] = (value + DV);
                }
                else
                {
                    this.t = 0;
                };
            };
        }

        bi_internal function fromArray(value:ByteArray, length:int, unsigned:Boolean=false):void
        {
            var x:int;
            var p:int = value.position;
            var i:int = (p + length);
            var sh:int;
            var k:int = 8;
            this.t = 0;
            this.s = 0;
            while (--i >= p)
            {
                x = (((i < value.length)) ? value[i] : 0);
                if (sh == 0)
                {
                    var _local_9 = this.t++;
                    this.a[_local_9] = x;
                }
                else
                {
                    if ((sh + k) > DB)
                    {
                        this.a[(this.t - 1)] = (this.a[(this.t - 1)] | ((x & ((1 << (DB - sh)) - 1)) << sh));
                        _local_9 = this.t++;
                        this.a[_local_9] = (x >> (DB - sh));
                    }
                    else
                    {
                        this.a[(this.t - 1)] = (this.a[(this.t - 1)] | (x << sh));
                    };
                };
                sh = (sh + k);
                if (sh >= DB)
                {
                    sh = (sh - DB);
                };
            };
            if (((!(unsigned)) && (((value[0] & 128) == 128))))
            {
                this.s = -1;
                if (sh > 0)
                {
                    this.a[(this.t - 1)] = (this.a[(this.t - 1)] | (((1 << (DB - sh)) - 1) << sh));
                };
            };
            this.clamp();
            value.position = Math.min((p + length), value.length);
        }

        bi_internal function clamp():void
        {
            var c:int = (this.s & DM);
            while ((((this.t > 0)) && ((this.a[(this.t - 1)] == c))))
            {
                this.t--;
            };
        }

        bi_internal function dlShiftTo(n:int, r:BigInteger):void
        {
            var i:int;
            i = (this.t - 1);
            while (i >= 0)
            {
                r.a[(i + n)] = this.a[i];
                i--;
            };
            i = (n - 1);
            while (i >= 0)
            {
                r.a[i] = 0;
                i--;
            };
            r.t = (this.t + n);
            r.s = this.s;
        }

        bi_internal function drShiftTo(n:int, r:BigInteger):void
        {
            var i:int;
            i = n;
            while (i < this.t)
            {
                r.a[(i - n)] = this.a[i];
                i++;
            };
            r.t = Math.max((this.t - n), 0);
            r.s = this.s;
        }

        bi_internal function lShiftTo(n:int, r:BigInteger):void
        {
            var i:int;
            var bs:int = (n % DB);
            var cbs:int = (DB - bs);
            var bm:int = ((1 << cbs) - 1);
            var ds:int = (n / DB);
            var c:int = ((this.s << bs) & DM);
            i = (this.t - 1);
            while (i >= 0)
            {
                r.a[((i + ds) + 1)] = ((this.a[i] >> cbs) | c);
                c = ((this.a[i] & bm) << bs);
                i--;
            };
            i = (ds - 1);
            while (i >= 0)
            {
                r.a[i] = 0;
                i--;
            };
            r.a[ds] = c;
            r.t = ((this.t + ds) + 1);
            r.s = this.s;
            r.clamp();
        }

        bi_internal function rShiftTo(n:int, r:BigInteger):void
        {
            var i:int;
            r.s = this.s;
            var ds:int = (n / DB);
            if (ds >= this.t)
            {
                r.t = 0;
                return;
            };
            var bs:int = (n % DB);
            var cbs:int = (DB - bs);
            var bm:int = ((1 << bs) - 1);
            r.a[0] = (this.a[ds] >> bs);
            i = (ds + 1);
            while (i < this.t)
            {
                r.a[((i - ds) - 1)] = (r.a[((i - ds) - 1)] | ((this.a[i] & bm) << cbs));
                r.a[(i - ds)] = (this.a[i] >> bs);
                i++;
            };
            if (bs > 0)
            {
                r.a[((this.t - ds) - 1)] = (r.a[((this.t - ds) - 1)] | ((this.s & bm) << cbs));
            };
            r.t = (this.t - ds);
            r.clamp();
        }

        bi_internal function subTo(v:BigInteger, r:BigInteger):void
        {
            var i:int;
            var c:int;
            var m:int = Math.min(v.t, this.t);
            while (i < m)
            {
                c = (c + (this.a[i] - v.a[i]));
                var _local_6 = i++;
                r.a[_local_6] = (c & DM);
                c = (c >> DB);
            };
            if (v.t < this.t)
            {
                c = (c - v.s);
                while (i < this.t)
                {
                    c = (c + this.a[i]);
                    _local_6 = i++;
                    r.a[_local_6] = (c & DM);
                    c = (c >> DB);
                };
                c = (c + this.s);
            }
            else
            {
                c = (c + this.s);
                while (i < v.t)
                {
                    c = (c - v.a[i]);
                    _local_6 = i++;
                    r.a[_local_6] = (c & DM);
                    c = (c >> DB);
                };
                c = (c - v.s);
            };
            r.s = (((c)<0) ? -1 : 0);
            if (c < -1)
            {
                _local_6 = i++;
                r.a[_local_6] = (DV + c);
            }
            else
            {
                if (c > 0)
                {
                    _local_6 = i++;
                    r.a[_local_6] = c;
                };
            };
            r.t = i;
            r.clamp();
        }

        bi_internal function am(i:int, x:int, w:BigInteger, j:int, c:int, n:int):int
        {
            var l:int;
            var h:int;
            var m:int;
            var xl:int = (x & 32767);
            var xh:int = (x >> 15);
            while (--n >= 0)
            {
                l = (this.a[i] & 32767);
                h = (this.a[i++] >> 15);
                m = ((xh * l) + (h * xl));
                l = ((((xl * l) + ((m & 32767) << 15)) + w.a[j]) + (c & 1073741823));
                c = ((((l >>> 30) + (m >>> 15)) + (xh * h)) + (c >>> 30));
                var _local_12 = j++;
                w.a[_local_12] = (l & 1073741823);
            };
            return (c);
        }

        bi_internal function multiplyTo(v:BigInteger, r:BigInteger):void
        {
            var x:BigInteger = this.abs();
            var y:BigInteger = v.abs();
            var i:int = x.t;
            r.t = (i + y.t);
            while (--i >= 0)
            {
                r.a[i] = 0;
            };
            i = 0;
            while (i < y.t)
            {
                r.a[(i + x.t)] = x.am(0, y.a[i], r, i, 0, x.t);
                i++;
            };
            r.s = 0;
            r.clamp();
            if (this.s != v.s)
            {
                ZERO.subTo(r, r);
            };
        }

        bi_internal function squareTo(r:BigInteger):void
        {
            var c:int;
            var x:BigInteger = this.abs();
            var i:int = (r.t = (2 * x.t));
            while (--i >= 0)
            {
                r.a[i] = 0;
            };
            i = 0;
            while (i < (x.t - 1))
            {
                c = x.am(i, x.a[i], r, (2 * i), 0, 1);
                if ((r.a[(i + x.t)] = (r.a[(i + x.t)] + x.am((i + 1), (2 * x.a[i]), r, ((2 * i) + 1), c, ((x.t - i) - 1)))) >= DV)
                {
                    r.a[(i + x.t)] = (r.a[(i + x.t)] - DV);
                    r.a[((i + x.t) + 1)] = 1;
                };
                i++;
            };
            if (r.t > 0)
            {
                r.a[(r.t - 1)] = (r.a[(r.t - 1)] + x.am(i, x.a[i], r, (2 * i), 0, 1));
            };
            r.s = 0;
            r.clamp();
        }

        bi_internal function divRemTo(m:BigInteger, q:BigInteger=null, r:BigInteger=null):void
        {
            var qd:int;
            var pm:BigInteger = m.abs();
            if (pm.t <= 0)
            {
                return;
            };
            var pt:BigInteger = this.abs();
            if (pt.t < pm.t)
            {
                if (q != null)
                {
                    q.fromInt(0);
                };
                if (r != null)
                {
                    this.copyTo(r);
                };
                return;
            };
            if (r == null)
            {
                r = this.nbi();
            };
            var y:BigInteger = this.nbi();
            var ts:int = this.s;
            var ms:int = m.s;
            var nsh:int = (DB - this.nbits(pm.a[(pm.t - 1)]));
            if (nsh > 0)
            {
                pm.lShiftTo(nsh, y);
                pt.lShiftTo(nsh, r);
            }
            else
            {
                pm.copyTo(y);
                pt.copyTo(r);
            };
            var ys:int = y.t;
            var y0:int = y.a[(ys - 1)];
            if (y0 == 0)
            {
                return;
            };
            var yt:Number = ((y0 * (1 << F1)) + (((ys)>1) ? (y.a[(ys - 2)] >> F2) : 0));
            var d1:Number = (FV / yt);
            var d2:Number = ((1 << F1) / yt);
            var e:Number = (1 << F2);
            var i:int = r.t;
            var j:int = (i - ys);
            var t:BigInteger = (((q)==null) ? this.nbi() : q);
            y.dlShiftTo(j, t);
            if (r.compareTo(t) >= 0)
            {
                var _local_5 = r.t++;
                r.a[_local_5] = 1;
                r.subTo(t, r);
            };
            ONE.dlShiftTo(ys, t);
            t.subTo(y, y);
            while (y.t < ys)
            {
                y.(y.t++, 0); //not popped
            };
            while (--j >= 0)
            {
                qd = (((r.a[--i])==y0) ? DM : ((Number(r.a[i]) * d1) + ((Number(r.a[(i - 1)]) + e) * d2)));
                if ((r.a[i] = (r.a[i] + y.am(0, qd, r, j, 0, ys))) < qd)
                {
                    y.dlShiftTo(j, t);
                    r.subTo(t, r);
                    while ((qd = (qd - 1)), r.a[i] < qd)
                    {
                        r.subTo(t, r);
                    };
                };
            };
            if (q != null)
            {
                r.drShiftTo(ys, q);
                if (ts != ms)
                {
                    ZERO.subTo(q, q);
                };
            };
            r.t = ys;
            r.clamp();
            if (nsh > 0)
            {
                r.rShiftTo(nsh, r);
            };
            if (ts < 0)
            {
                ZERO.subTo(r, r);
            };
        }

        bi_internal function invDigit():int
        {
            if (this.t < 1)
            {
                return (0);
            };
            var x:int = this.a[0];
            if ((x & 1) == 0)
            {
                return (0);
            };
            var y:int = (x & 3);
            y = ((y * (2 - ((x & 15) * y))) & 15);
            y = ((y * (2 - ((x & 0xFF) * y))) & 0xFF);
            y = ((y * (2 - (((x & 0xFFFF) * y) & 0xFFFF))) & 0xFFFF);
            y = ((y * (2 - ((x * y) % DV))) % DV);
            return ((((y)>0) ? (DV - y) : -(y)));
        }

        bi_internal function isEven():Boolean
        {
            return (((((this.t)>0) ? (this.a[0] & 1) : this.s) == 0));
        }

        bi_internal function exp(e:int, z:IReduction):BigInteger
        {
            var _local_7:BigInteger;
            if ((((e > 0xFFFFFFFF)) || ((e < 1))))
            {
                return (ONE);
            };
            var r:BigInteger = this.nbi();
            var r2:BigInteger = this.nbi();
            var g:BigInteger = z.convert(this);
            var i:int = (this.nbits(e) - 1);
            g.copyTo(r);
            while (--i >= 0)
            {
                z.sqrTo(r, r2);
                if ((e & (1 << i)) > 0)
                {
                    z.mulTo(r2, g, r);
                }
                else
                {
                    _local_7 = r;
                    r = r2;
                    r2 = _local_7;
                };
            };
            return (z.revert(r));
        }

        bi_internal function intAt(str:String, index:int):int
        {
            return (parseInt(str.charAt(index), 36));
        }

        protected function nbi()
        {
            return (new BigInteger());
        }

        public function clone():BigInteger
        {
            var r:BigInteger = new BigInteger();
            this.copyTo(r);
            return (r);
        }

        public function intValue():int
        {
            if (this.s < 0)
            {
                if (this.t == 1)
                {
                    return ((this.a[0] - DV));
                };
                if (this.t == 0)
                {
                    return (-1);
                };
            }
            else
            {
                if (this.t == 1)
                {
                    return (this.a[0]);
                };
                if (this.t == 0)
                {
                    return (0);
                };
            };
            return ((((this.a[1] & ((1 << (32 - DB)) - 1)) << DB) | this.a[0]));
        }

        public function byteValue():int
        {
            return ((((this.t)==0) ? this.s : ((this.a[0] << 24) >> 24)));
        }

        public function shortValue():int
        {
            return ((((this.t)==0) ? this.s : ((this.a[0] << 16) >> 16)));
        }

        protected function chunkSize(r:Number):int
        {
            return (Math.floor(((Math.LN2 * DB) / Math.log(r))));
        }

        public function sigNum():int
        {
            if (this.s < 0)
            {
                return (-1);
            };
            if ((((this.t <= 0)) || ((((this.t == 1)) && ((this.a[0] <= 0))))))
            {
                return (0);
            };
            return (1);
        }

        protected function toRadix(b:uint=10):String
        {
            if ((((((this.sigNum() == 0)) || ((b < 2)))) || ((b > 32))))
            {
                return ("0");
            };
            var cs:int = this.chunkSize(b);
            var a:Number = Math.pow(b, cs);
            var d:BigInteger = nbv(a);
            var y:BigInteger = this.nbi();
            var z:BigInteger = this.nbi();
            var r:String = "";
            this.divRemTo(d, y, z);
            while (y.sigNum() > 0)
            {
                r = ((a + z.intValue()).toString(b).substr(1) + r);
                y.divRemTo(d, y, z);
            };
            return ((z.intValue().toString(b) + r));
        }

        protected function fromRadix(s:String, b:int=10):void
        {
            var x:int;
            this.fromInt(0);
            var cs:int = this.chunkSize(b);
            var d:Number = Math.pow(b, cs);
            var mi:Boolean;
            var j:int;
            var w:int;
            var i:int;
            while (i < s.length)
            {
                x = this.intAt(s, i);
                if (x < 0)
                {
                    if ((((s.charAt(i) == "-")) && ((this.sigNum() == 0))))
                    {
                        mi = true;
                    };
                }
                else
                {
                    w = ((b * w) + x);
                    if (++j >= cs)
                    {
                        this.dMultiply(d);
                        this.dAddOffset(w, 0);
                        j = 0;
                        w = 0;
                    };
                };
                i++;
            };
            if (j > 0)
            {
                this.dMultiply(Math.pow(b, j));
                this.dAddOffset(w, 0);
            };
            if (mi)
            {
                BigInteger.ZERO.subTo(this, this);
            };
        }

        public function toByteArray():ByteArray
        {
            var d:int;
            var i:int = this.t;
            var r:ByteArray = new ByteArray();
            r[0] = this.s;
            var p:int = (DB - ((i * DB) % 8));
            var k:int;
            if (i-- > 0)
            {
                if ((((p < DB)) && (!(((d = (this.a[i] >> p)) == ((this.s & DM) >> p))))))
                {
                    var _local_6 = k++;
                    r[_local_6] = (d | (this.s << (DB - p)));
                };
                while (i >= 0)
                {
                    if (p < 8)
                    {
                        d = ((this.a[i] & ((1 << p) - 1)) << (8 - p));
                        var _temp_1 = d;
                        p = (p + (DB - 8));
                        d = (_temp_1 | (this.a[--i] >> p));
                    }
                    else
                    {
                        p = (p - 8);
                        d = ((this.a[i] >> p) & 0xFF);
                        if (p <= 0)
                        {
                            p = (p + DB);
                            i--;
                        };
                    };
                    if ((d & 128) != 0)
                    {
                        d = (d | -256);
                    };
                    if ((((k == 0)) && (!(((this.s & 128) == (d & 128))))))
                    {
                        k++;
                    };
                    if ((((k > 0)) || (!((d == this.s)))))
                    {
                        _local_6 = k++;
                        r[_local_6] = d;
                    };
                };
            };
            return (r);
        }

        public function equals(a:BigInteger):Boolean
        {
            return ((this.compareTo(a) == 0));
        }

        public function min(a:BigInteger):BigInteger
        {
            return ((((this.compareTo(a))<0) ? this : a));
        }

        public function max(a:BigInteger):BigInteger
        {
            return ((((this.compareTo(a))>0) ? this : a));
        }

        protected function bitwiseTo(a:BigInteger, op:Function, r:BigInteger):void
        {
            var i:int;
            var f:int;
            var m:int = Math.min(a.t, this.t);
            i = 0;
            while (i < m)
            {
                r.a[i] = op(this.a[i], a.a[i]);
                i++;
            };
            if (a.t < this.t)
            {
                f = (a.s & DM);
                i = m;
                while (i < this.t)
                {
                    r.a[i] = op(this.a[i], f);
                    i++;
                };
                r.t = this.t;
            }
            else
            {
                f = (this.s & DM);
                i = m;
                while (i < a.t)
                {
                    r.a[i] = op(f, a.a[i]);
                    i++;
                };
                r.t = a.t;
            };
            r.s = op(this.s, a.s);
            r.clamp();
        }

        private function op_and(x:int, y:int):int
        {
            return ((x & y));
        }

        public function and(a:BigInteger):BigInteger
        {
            var r:BigInteger = new BigInteger();
            this.bitwiseTo(a, this.op_and, r);
            return (r);
        }

        private function op_or(x:int, y:int):int
        {
            return ((x | y));
        }

        public function or(a:BigInteger):BigInteger
        {
            var r:BigInteger = new BigInteger();
            this.bitwiseTo(a, this.op_or, r);
            return (r);
        }

        private function op_xor(x:int, y:int):int
        {
            return ((x ^ y));
        }

        public function xor(a:BigInteger):BigInteger
        {
            var r:BigInteger = new BigInteger();
            this.bitwiseTo(a, this.op_xor, r);
            return (r);
        }

        private function op_andnot(x:int, y:int):int
        {
            return ((x & ~(y)));
        }

        public function andNot(a:BigInteger):BigInteger
        {
            var r:BigInteger = new BigInteger();
            this.bitwiseTo(a, this.op_andnot, r);
            return (r);
        }

        public function not():BigInteger
        {
            var r:BigInteger = new BigInteger();
            var i:int;
            while (i < this.t)
            {
                r[i] = (DM & ~(this.a[i]));
                i++;
            };
            r.t = this.t;
            r.s = ~(this.s);
            return (r);
        }

        public function shiftLeft(n:int):BigInteger
        {
            var r:BigInteger = new BigInteger();
            if (n < 0)
            {
                this.rShiftTo(-(n), r);
            }
            else
            {
                this.lShiftTo(n, r);
            };
            return (r);
        }

        public function shiftRight(n:int):BigInteger
        {
            var r:BigInteger = new BigInteger();
            if (n < 0)
            {
                this.lShiftTo(-(n), r);
            }
            else
            {
                this.rShiftTo(n, r);
            };
            return (r);
        }

        private function lbit(x:int):int
        {
            if (x == 0)
            {
                return (-1);
            };
            var r:int;
            if ((x & 0xFFFF) == 0)
            {
                x = (x >> 16);
                r = (r + 16);
            };
            if ((x & 0xFF) == 0)
            {
                x = (x >> 8);
                r = (r + 8);
            };
            if ((x & 15) == 0)
            {
                x = (x >> 4);
                r = (r + 4);
            };
            if ((x & 3) == 0)
            {
                x = (x >> 2);
                r = (r + 2);
            };
            if ((x & 1) == 0)
            {
                r++;
            };
            return (r);
        }

        public function getLowestSetBit():int
        {
            var i:int;
            while (i < this.t)
            {
                if (this.a[i] != 0)
                {
                    return (((i * DB) + this.lbit(this.a[i])));
                };
                i++;
            };
            if (this.s < 0)
            {
                return ((this.t * DB));
            };
            return (-1);
        }

        private function cbit(x:int):int
        {
            var r:uint;
            while (x != 0)
            {
                x = (x & (x - 1));
                r++;
            };
            return (r);
        }

        public function bitCount():int
        {
            var r:int;
            var x:int = (this.s & DM);
            var i:int;
            while (i < this.t)
            {
                r = (r + this.cbit((this.a[i] ^ x)));
                i++;
            };
            return (r);
        }

        public function testBit(n:int):Boolean
        {
            var j:int = Math.floor((n / DB));
            if (j >= this.t)
            {
                return (!((this.s == 0)));
            };
            return (!(((this.a[j] & (1 << (n % DB))) == 0)));
        }

        protected function changeBit(n:int, op:Function):BigInteger
        {
            var r:BigInteger = BigInteger.ONE.shiftLeft(n);
            this.bitwiseTo(r, op, r);
            return (r);
        }

        public function setBit(n:int):BigInteger
        {
            return (this.changeBit(n, this.op_or));
        }

        public function clearBit(n:int):BigInteger
        {
            return (this.changeBit(n, this.op_andnot));
        }

        public function flipBit(n:int):BigInteger
        {
            return (this.changeBit(n, this.op_xor));
        }

        protected function addTo(a:BigInteger, r:BigInteger):void
        {
            var i:int;
            var c:int;
            var m:int = Math.min(a.t, this.t);
            while (i < m)
            {
                c = (c + (this.a[i] + a.a[i]));
                var _local_6 = i++;
                r.a[_local_6] = (c & DM);
                c = (c >> DB);
            };
            if (a.t < this.t)
            {
                c = (c + a.s);
                while (i < this.t)
                {
                    c = (c + this.a[i]);
                    _local_6 = i++;
                    r.a[_local_6] = (c & DM);
                    c = (c >> DB);
                };
                c = (c + this.s);
            }
            else
            {
                c = (c + this.s);
                while (i < a.t)
                {
                    c = (c + a.a[i]);
                    _local_6 = i++;
                    r.a[_local_6] = (c & DM);
                    c = (c >> DB);
                };
                c = (c + a.s);
            };
            r.s = (((c)<0) ? -1 : 0);
            if (c > 0)
            {
                _local_6 = i++;
                r.a[_local_6] = c;
            }
            else
            {
                if (c < -1)
                {
                    _local_6 = i++;
                    r.a[_local_6] = (DV + c);
                };
            };
            r.t = i;
            r.clamp();
        }

        public function add(a:BigInteger):BigInteger
        {
            var r:BigInteger = new BigInteger();
            this.addTo(a, r);
            return (r);
        }

        public function subtract(a:BigInteger):BigInteger
        {
            var r:BigInteger = new BigInteger();
            this.subTo(a, r);
            return (r);
        }

        public function multiply(a:BigInteger):BigInteger
        {
            var r:BigInteger = new BigInteger();
            this.multiplyTo(a, r);
            return (r);
        }

        public function divide(a:BigInteger):BigInteger
        {
            var r:BigInteger = new BigInteger();
            this.divRemTo(a, r, null);
            return (r);
        }

        public function remainder(a:BigInteger):BigInteger
        {
            var r:BigInteger = new BigInteger();
            this.divRemTo(a, null, r);
            return (r);
        }

        public function divideAndRemainder(a:BigInteger):Array
        {
            var q:BigInteger = new BigInteger();
            var r:BigInteger = new BigInteger();
            this.divRemTo(a, q, r);
            return ([q, r]);
        }

        bi_internal function dMultiply(n:int):void
        {
            this.a[this.t] = this.am(0, (n - 1), this, 0, 0, this.t);
            this.t++;
            this.clamp();
        }

        bi_internal function dAddOffset(n:int, w:int):void
        {
            while (this.t <= w)
            {
                var _local_3 = this.t++;
                this.a[_local_3] = 0;
            };
            this.a[w] = (this.a[w] + n);
            while (this.a[w] >= DV)
            {
                this.a[w] = (this.a[w] - DV);
                if (++w >= this.t)
                {
                    _local_3 = this.t++;
                    this.a[_local_3] = 0;
                };
                _local_3 = this.a;
                var _local_4 = w;
                var _local_5 = (_local_3[_local_4] + 1);
                _local_3[_local_4] = _local_5;
            };
        }

        public function pow(e:int):BigInteger
        {
            return (this.exp(e, new NullReduction()));
        }

        bi_internal function multiplyLowerTo(a:BigInteger, n:int, r:BigInteger):void
        {
            var j:int;
            var i:int = Math.min((this.t + a.t), n);
            r.s = 0;
            r.t = i;
            while (i > 0)
            {
                var _local_6 = --i;
                r.a[_local_6] = 0;
            };
            j = (r.t - this.t);
            while (i < j)
            {
                r.a[(i + this.t)] = this.am(0, a.a[i], r, i, 0, this.t);
                i++;
            };
            j = Math.min(a.t, n);
            while (i < j)
            {
                this.am(0, a.a[i], r, i, 0, (n - i));
                i++;
            };
            r.clamp();
        }

        bi_internal function multiplyUpperTo(a:BigInteger, n:int, r:BigInteger):void
        {
            n--;
            var i:int = (r.t = ((this.t + a.t) - n));
            r.s = 0;
            while (--i >= 0)
            {
                r.a[i] = 0;
            };
            i = Math.max((n - this.t), 0);
            while (i < a.t)
            {
                r.a[((this.t + i) - n)] = this.am((n - i), a.a[i], r, 0, 0, ((this.t + i) - n));
                i++;
            };
            r.clamp();
            r.drShiftTo(1, r);
        }

        public function modPow(e:BigInteger, m:BigInteger):BigInteger
        {
            var k:int;
            var z:IReduction;
            var w:int;
            var t:BigInteger;
            var g2:BigInteger;
            var i:int = e.bitLength();
            var r:BigInteger = nbv(1);
            if (i <= 0)
            {
                return (r);
            };
            if (i < 18)
            {
                k = 1;
            }
            else
            {
                if (i < 48)
                {
                    k = 3;
                }
                else
                {
                    if (i < 144)
                    {
                        k = 4;
                    }
                    else
                    {
                        if (i < 0x0300)
                        {
                            k = 5;
                        }
                        else
                        {
                            k = 6;
                        };
                    };
                };
            };
            if (i < 8)
            {
                z = new ClassicReduction(m);
            }
            else
            {
                if (m.isEven())
                {
                    z = new BarrettReduction(m);
                }
                else
                {
                    z = new MontgomeryReduction(m);
                };
            };
            var g:Array = [];
            var n:int = 3;
            var k1:int = (k - 1);
            var km:int = ((1 << k) - 1);
            g[1] = z.convert(this);
            if (k > 1)
            {
                g2 = new BigInteger();
                z.sqrTo(g[1], g2);
                while (n <= km)
                {
                    g[n] = new BigInteger();
                    z.mulTo(g2, g[(n - 2)], g[n]);
                    n = (n + 2);
                };
            };
            var j:int = (e.t - 1);
            var is1:Boolean = true;
            var r2:BigInteger = new BigInteger();
            i = (this.nbits(e.a[j]) - 1);
            while (j >= 0)
            {
                if (i >= k1)
                {
                    w = ((e.a[j] >> (i - k1)) & km);
                }
                else
                {
                    w = ((e.a[j] & ((1 << (i + 1)) - 1)) << (k1 - i));
                    if (j > 0)
                    {
                        w = (w | (e.a[(j - 1)] >> ((DB + i) - k1)));
                    };
                };
                n = k;
                while ((w & 1) == 0)
                {
                    w = (w >> 1);
                    n--;
                };
                i = (i - n);
                if (i < 0)
                {
                    i = (i + DB);
                    j--;
                };
                if (is1)
                {
                    g[w].copyTo(r);
                    is1 = false;
                }
                else
                {
                    while (n > 1)
                    {
                        z.sqrTo(r, r2);
                        z.sqrTo(r2, r);
                        n = (n - 2);
                    };
                    if (n > 0)
                    {
                        z.sqrTo(r, r2);
                    }
                    else
                    {
                        t = r;
                        r = r2;
                        r2 = t;
                    };
                    z.mulTo(r2, g[w], r);
                };
                while ((((j >= 0)) && (((e.a[j] & (1 << i)) == 0))))
                {
                    z.sqrTo(r, r2);
                    t = r;
                    r = r2;
                    r2 = t;
                    if (--i < 0)
                    {
                        i = (DB - 1);
                        j--;
                    };
                };
            };
            return (z.revert(r));
        }

        public function gcd(a:BigInteger):BigInteger
        {
            var t:BigInteger;
            var x:BigInteger = (((this.s)<0) ? this.negate() : this.clone());
            var y:BigInteger = (((a.s)<0) ? a.negate() : a.clone());
            if (x.compareTo(y) < 0)
            {
                t = x;
                x = y;
                y = t;
            };
            var i:int = x.getLowestSetBit();
            var g:int = y.getLowestSetBit();
            if (g < 0)
            {
                return (x);
            };
            if (i < g)
            {
                g = i;
            };
            if (g > 0)
            {
                x.rShiftTo(g, x);
                y.rShiftTo(g, y);
            };
            while (x.sigNum() > 0)
            {
                i = x.getLowestSetBit();
                if (i > 0)
                {
                    x.rShiftTo(i, x);
                };
                i = y.getLowestSetBit();
                if (i > 0)
                {
                    y.rShiftTo(i, y);
                };
                if (x.compareTo(y) >= 0)
                {
                    x.subTo(y, x);
                    x.rShiftTo(1, x);
                }
                else
                {
                    y.subTo(x, y);
                    y.rShiftTo(1, y);
                };
            };
            if (g > 0)
            {
                y.lShiftTo(g, y);
            };
            return (y);
        }

        protected function modInt(n:int):int
        {
            var _local_4:int;
            if (n <= 0)
            {
                return (0);
            };
            var d:int = (DV % n);
            var r:int = (((this.s)<0) ? (n - 1) : 0);
            if (this.t > 0)
            {
                if (d == 0)
                {
                    r = (this.a[0] % n);
                }
                else
                {
                    _local_4 = (this.t - 1);
                    while (_local_4 >= 0)
                    {
                        r = (((d * r) + this.a[_local_4]) % n);
                        _local_4--;
                    };
                };
            };
            return (r);
        }

        public function modInverse(m:BigInteger):BigInteger
        {
            var ac:Boolean = m.isEven();
            if (((((this.isEven()) && (ac))) || ((m.sigNum() == 0))))
            {
                return (BigInteger.ZERO);
            };
            var u:BigInteger = m.clone();
            var v:BigInteger = this.clone();
            var a:BigInteger = nbv(1);
            var b:BigInteger = nbv(0);
            var c:BigInteger = nbv(0);
            var d:BigInteger = nbv(1);
            while (u.sigNum() != 0)
            {
                while (u.isEven())
                {
                    u.rShiftTo(1, u);
                    if (ac)
                    {
                        if (((!(a.isEven())) || (!(b.isEven()))))
                        {
                            a.addTo(this, a);
                            b.subTo(m, b);
                        };
                        a.rShiftTo(1, a);
                    }
                    else
                    {
                        if (!(b.isEven()))
                        {
                            b.subTo(m, b);
                        };
                    };
                    b.rShiftTo(1, b);
                };
                while (v.isEven())
                {
                    v.rShiftTo(1, v);
                    if (ac)
                    {
                        if (((!(c.isEven())) || (!(d.isEven()))))
                        {
                            c.addTo(this, c);
                            d.subTo(m, d);
                        };
                        c.rShiftTo(1, c);
                    }
                    else
                    {
                        if (!(d.isEven()))
                        {
                            d.subTo(m, d);
                        };
                    };
                    d.rShiftTo(1, d);
                };
                if (u.compareTo(v) >= 0)
                {
                    u.subTo(v, u);
                    if (ac)
                    {
                        a.subTo(c, a);
                    };
                    b.subTo(d, b);
                }
                else
                {
                    v.subTo(u, v);
                    if (ac)
                    {
                        c.subTo(a, c);
                    };
                    d.subTo(b, d);
                };
            };
            if (v.compareTo(BigInteger.ONE) != 0)
            {
                return (BigInteger.ZERO);
            };
            if (d.compareTo(m) >= 0)
            {
                return (d.subtract(m));
            };
            if (d.sigNum() < 0)
            {
                d.addTo(m, d);
            }
            else
            {
                return (d);
            };
            if (d.sigNum() < 0)
            {
                return (d.add(m));
            };
            return (d);
        }

        public function isProbablePrime(t:int):Boolean
        {
            var i:int;
            var m:int;
            var j:int;
            var x:BigInteger = this.abs();
            if ((((x.t == 1)) && ((x.a[0] <= lowprimes[(lowprimes.length - 1)]))))
            {
                i = 0;
                while (i < lowprimes.length)
                {
                    if (x[0] == lowprimes[i])
                    {
                        return (true);
                    };
                    i++;
                };
                return (false);
            };
            if (x.isEven())
            {
                return (false);
            };
            i = 1;
            while (i < lowprimes.length)
            {
                m = lowprimes[i];
                j = (i + 1);
                while ((((j < lowprimes.length)) && ((m < lplim))))
                {
                    m = (m * lowprimes[j++]);
                };
                m = x.modInt(m);
                while (i < j)
                {
                    if ((m % lowprimes[i++]) == 0)
                    {
                        return (false);
                    };
                };
            };
            return (x.millerRabin(t));
        }

        protected function millerRabin(t:int):Boolean
        {
            var y:BigInteger;
            var j:int;
            var n1:BigInteger = this.subtract(BigInteger.ONE);
            var k:int = n1.getLowestSetBit();
            if (k <= 0)
            {
                return (false);
            };
            var r:BigInteger = n1.shiftRight(k);
            t = ((t + 1) >> 1);
            if (t > lowprimes.length)
            {
                t = lowprimes.length;
            };
            var a:BigInteger = new BigInteger();
            var i:int;
            while (i < t)
            {
                a.fromInt(lowprimes[i]);
                y = a.modPow(r, this);
                if (((!((y.compareTo(BigInteger.ONE) == 0))) && (!((y.compareTo(n1) == 0)))))
                {
                    j = 1;
                    while ((((j++ < k)) && (!((y.compareTo(n1) == 0)))))
                    {
                        y = y.modPowInt(2, this);
                        if (y.compareTo(BigInteger.ONE) == 0)
                        {
                            return (false);
                        };
                    };
                    if (y.compareTo(n1) != 0)
                    {
                        return (false);
                    };
                };
                i++;
            };
            return (true);
        }

        public function primify(bits:int, t:int):void
        {
            if (!(this.testBit((bits - 1))))
            {
                this.bitwiseTo(BigInteger.ONE.shiftLeft((bits - 1)), this.op_or, this);
            };
            if (this.isEven())
            {
                this.dAddOffset(1, 0);
            };
            while (!(this.isProbablePrime(t)))
            {
                this.dAddOffset(2, 0);
                while (this.bitLength() > bits)
                {
                    this.subTo(BigInteger.ONE.shiftLeft((bits - 1)), this);
                };
            };
        }


    }
}//package com.hurlant.math

