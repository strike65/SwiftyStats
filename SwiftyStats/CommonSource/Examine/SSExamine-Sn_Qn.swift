//
//  SSExamine-Stats.swift
//  SwiftyStats
//
//  Created by strike65 on 03.07.17.
//
/*
 
 This a Swift version of the gsl version (see below)
 Copyright (c) 2018 strike65
 
 GNU GPL 3+
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, version 3 of the License.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 */

/* This is a merge of the C version of original files  qn.f and sn.f,
 * translated by f2c (version 20010821).           ====    ====
 * and then by f2c-clean,v 1.9 2000/01/13 13:46:53
 * and further clean-edited manually by Martin Maechler.
 *
 * Further added interface functions to be called via .C() from R or S-plus
 * Note that Peter Rousseeuw has explicitely given permission to
 * use his code under the GPL for the R project.
 */


/* Original comments by the authors of the Fortran original code,
 * (merged for Qn & Sn in one file by M.M.):
 
 This file contains fortran functions for two new robust estimators
 of scale denoted as Qn and Sn, decribed in Rousseeuw and Croux (1993).
 These estimators have a high breakdown point and a bounded influence
 function. The implementation given here is very fast (running in
 O(n logn) time) and needs little storage space.
 
 Rousseeuw, P.J. and Croux, C. (1993)
 Alternatives to the Median Absolute Deviation",
 Journal of the American Statistical Association, Vol. 88, 1273-1283.
 
 For both estimators, implementations in the pascal language can be
 obtained from the original authors.
 
 This software may be used and copied freely for scientific
 and/or non-commercial purposes, provided reference is made
 to the abovementioned paper.
 
 Note by MM: We have explicit permission from P.Rousseeuw to
 licence it under the GNU Public Licence.
 */


import Foundation
#if os(macOS) || os(iOS)
import os.log
#endif


// Definition of statistics
extension SSExamine {
    
    
    fileprivate func sn0() -> FPT? {
        if !self.isNotEmptyAndNumeric {
            return nil
        }
        var medA, medB: FPT
        var diff, half, Amin, Amax, even, length: Int
        var leftA, leftB, nA, nB, tryA, tryB, rightA: Int
        let n = self.sampleSize
        let np1_2: Int = (n + 1) / 2
        var work: [FPT] = Array<FPT>.init(repeating: 0, count: n)
        let sorted_data: Array<SSElement> = self.elementsAsArray(sortOrder: .ascending)!
        var val1: FPT =  Helpers.makeFP( sorted_data[n / 2])
        var val2: FPT =  Helpers.makeFP(sorted_data[0])
        
        work[0] = val1 - val2
        
        /* first half for() loop : */
        for i in stride(from: 2, through: np1_2, by: 1) {
            nA = i - 1
            nB = n - i
            diff = nB - nA
            leftA = 1
            leftB = 1
            rightA = nB
            Amin = diff / 2 + 1
            Amax = diff / 2 + nA
            
            while (leftA < rightA) {
                length = rightA - leftA + 1
                even = 1 - length % 2
                half = (length - 1) / 2
                tryA = leftA + half
                tryB = leftB + half
                if (tryA < Amin) {
                    leftA = tryA + even
                }
                else {
                    if (tryA > Amax) {
                        rightA = tryA
                        leftB = tryB + even
                    }
                    else {
                        val1 =  Helpers.makeFP(sorted_data[i - 1])
                        val2 =  Helpers.makeFP(sorted_data[i - tryA + Amin - 2])
                        medA = val1 - val2
                        val1 =  Helpers.makeFP(sorted_data[tryB + i - 1])
                        val2 =  Helpers.makeFP(sorted_data[i - 1])
                        medB = val1 - val2
                        if (medA >= medB) {
                            rightA = tryA
                            leftB = tryB + even
                        }
                        else {
                            leftA = tryA + even
                        }
                    }
                }
            } /* while */
            
            if (leftA > Amax) {
                val1 =  Helpers.makeFP(sorted_data[leftB + i - 1])
                val2 =  Helpers.makeFP(sorted_data[i - 1])
                work[i - 1] = val1 - val2
            }
            else {
                val1 =  Helpers.makeFP(sorted_data[i - 1])
                val2 =  Helpers.makeFP(sorted_data[i - leftA + Amin - 2])
                medA = val1 - val2
                val1 =  Helpers.makeFP(sorted_data[leftB + i - 1])
                val2 =  Helpers.makeFP(sorted_data[i - 1])
                medB = val1 - val2
                work[i - 1] = min(medA, medB)
            }
        }
        
        /* second half for() loop : */
        for i in stride(from: np1_2 + 1, through: self.sampleSize - 1, by: 1) {
            nA = n - i
            nB = i - 1
            diff = nB - nA
            leftA = 1
            leftB = 1
            rightA = nB
            Amin = diff / 2 + 1
            Amax = diff / 2 + nA
            
            while (leftA < rightA) {
                length = rightA - leftA + 1
                even = 1 - length % 2
                half = (length - 1) / 2
                tryA = leftA + half
                tryB = leftB + half
                
                if (tryA < Amin) {
                    leftA = tryA + even
                }
                else {
                    if (tryA > Amax) {
                        rightA = tryA
                        leftB = tryB + even
                    }
                    else {
                        val1 =  Helpers.makeFP(sorted_data[i + tryA - Amin])
                        val2 =  Helpers.makeFP(sorted_data[i - 1])
                        medA = val1 - val2
                        val1 =  Helpers.makeFP(sorted_data[i - 1])
                        val2 =  Helpers.makeFP(sorted_data[i - tryB - 1])
                        medB = val1 - val2
                        if (medA >= medB) {
                            rightA = tryA
                            leftB = tryB + even
                        }
                        else {
                            leftA = tryA + even
                        }
                    }
                }
            } /* while */
            
            if (leftA > Amax) {
                val1 =  Helpers.makeFP(sorted_data[i - 1])
                val2 =  Helpers.makeFP(sorted_data[i - leftB - 1])
                work[i - 1] = val1 - val2
            }
            else {
                val1 =  Helpers.makeFP(sorted_data[i + leftA - Amin])
                val2 =  Helpers.makeFP(sorted_data[i - 1])
                medA = val1 - val2
                val1 =  Helpers.makeFP(sorted_data[i - 1])
                val2 =  Helpers.makeFP(sorted_data[i - leftB - 1])
                medB = val1 - val2
                work[i - 1] = min(medA, medB)
            }
        }
        
        val1 =  Helpers.makeFP(sorted_data[n - 1])
        val2 =  Helpers.makeFP(sorted_data[np1_2 - 1])
        work[n - 1] = val1 - val2
        /* sort work array */
        return work.sorted(by: {$0 < $1})[np1_2 - 1]
    }
    
    
    /// Returns the Sn statistics according to Christophe Croux and Peter Rousseeuw
    ///
    /// Sn is a unbiased estimate of the standard deviation of Gaussian distributed data.
    /// The returned result is bias corrected for small samples.
    /// ###Note###
    ///
    /// Original Fortran code written by Christophe Croux and Peter Rousseeuw
    /// This Swift version was ported from a C version by Martin Maechler, maechler@R-project.org
    public var Sn: FPT? {
        get {
            if !self.isNotEmptyAndNumeric {
                return nil
            }
            else {
                if let sn0 = self.sn0() {
                    var cn: FPT = 1
                    let scale: FPT =  Helpers.makeFP(1.1926)
                    /* determine correction factor for finite sample bias */
                    let n: Int = self.sampleSize
                    if (n <= 9) {
                        if (n == 2) {
                            cn =  Helpers.makeFP(0.743)
                        }
                        else if (n == 3) {
                            cn =  Helpers.makeFP(1.851)
                        }
                        else if (n == 4) {
                            cn =  Helpers.makeFP(0.954)
                        }
                        else if (n == 5) {
                            cn =  Helpers.makeFP(1.351)
                        }
                        else if (n == 6) {
                            cn =  Helpers.makeFP(0.993)
                        }
                        else if (n == 7) {
                            cn =  Helpers.makeFP(1.198)
                        }
                        else if (n == 8) {
                            cn =  Helpers.makeFP(1.005)
                        }
                        else if (n == 9) {
                            cn =  Helpers.makeFP(1.131)
                        }
                    }
                    else if (n % 2 == 1) /* n odd, >= 11 */
                    {
                        
                        cn =  Helpers.makeFP(n) / ( Helpers.makeFP(n) -  Helpers.makeFP(0.9 ))
                    }
                    let sn = scale * cn * sn0
                    return sn
                }
                else {
                    return nil
                }
            }
        }
    }

    fileprivate func qn0() -> FPT? {
        if !self.isNotEmptyAndNumeric {
            return nil
        }
        let n: FPT =  Helpers.makeFP(self.sampleSize)
        let ni = self.sampleSize
        let sorted_data:Array<SSElement> = self.elementsAsArray(sortOrder: .ascending)!
        var a_srt: Array<FPT> = Array<FPT>.init(repeating: 0, count: ni)
        var a_cand:Array<FPT> = Array<FPT>.init(repeating: 0, count: ni)
        var work:Array<FPT> = Array<FPT>.init(repeating: 0, count: ni)
        var left: Array<Int> = Array<Int>.init(repeating: 0, count: ni)
        var right: Array<Int> = Array<Int>.init(repeating: 0, count: ni)
        var p: Array<Int> = Array<Int>.init(repeating: 0, count: ni)
        var q: Array<Int> = Array<Int>.init(repeating: 0, count: ni)
        var weight: Array<Int> = Array<Int>.init(repeating: 0, count: ni)
        var trial: FPT = 0
        var found: Bool = false
        
        var h, j, jh: Int
        
        /* following should be `long long int' : they can be of order n^2 */
        var k, knew, nl,nr, sump, sumq: Int64
        
        /* check for quick return */
        if (n < 2) {
            return 0
        }
        
        h = Helpers.integerValue(n / 2 + 1)
        k = Int64(h * (h - 1) / 2)
        
        for i in stride(from: 0, to: ni, by: 1) {
            left[i] = ni - i + 1
            right[i] = (i <= h) ? ni : ni - (i - h)
            /* the n - (i-h) is from the paper; original code had `n' */
        }
        
        nl = Int64(ni * (ni + 1) / 2)
        nr = Int64(ni * ni)
        knew = k + nl           /* = k + (n+1 \over 2) */
        
        /* L200: */
        
        var val1: FPT
        var val2: FPT
        while (!found && (nr - nl > ni)) {
            j = 0
            /* Truncation to float : try to make sure that the same values are got later (guard bits !) */
            for i in stride(from: 1, to: ni, by: 1) {
                if (left[i] <= right[i]) {
                    weight[j] = right[i] - left[i] + 1
                    jh = left[i] + weight[j] / 2
                    val1 =  Helpers.makeFP(sorted_data[i])
                    val2 =  Helpers.makeFP(sorted_data[ni - jh])
                    work[j] = val1 - val2
                    j += 1
                }
            }
            
            trial = qn_whimed(a: &work, w: &weight, n: &j, a_cand: &a_cand, a_srt: &a_srt, w_cand: &p)
            j = 0
            for i in stride(from: ni - 1, through: 0, by: -1) {
                val1 =  Helpers.makeFP(sorted_data[i])
                while (j < ni && (val1 -  Helpers.makeFP(sorted_data[ni - j - 1])) < trial) {
                    j += 1
                }
                p[i] = j
            }
            
            j = ni + 1;
            for i in stride(from: 0, to: ni, by: 1) {
                val1 =  Helpers.makeFP(sorted_data[i])
                while ((val1 -  Helpers.makeFP(sorted_data[ni - j + 1])) > trial) {
                    j -= 1
                }
                q[i] = j
            }
            
            sump = 0;
            sumq = 0;
            
            for i in stride(from: 0, to: ni, by: 1) {
                sump += Int64(p[i])
                sumq += Int64(q[i] - 1)
            }
            
            if (knew <= sump) {
                for i in stride(from: 0, to: ni, by: 1) {
                    right[i] = p[i]
                }
                nr = sump
            }
            else if (knew > sumq) {
                for i in stride(from: 0, to: ni, by: 1) {
                    left[i] = q[i]
                }
                nl = sumq
            }
            else { /* sump < knew <= sumq */
                found = true
            }
        } /* while */
        
        if (found) {
            return trial
        }
        else {
            j = 0
            for i in stride(from: 1, to: ni, by: 1) {
                for jj in stride(from: left[i], through: right[i], by: 1) {
                    val1 =  Helpers.makeFP(sorted_data[i])
                    val2 =  Helpers.makeFP(sorted_data[ni - jj])
                    work[j] = val1 - val2
                    j += 1
                } /* j will be = sum_{i=2}^n (right[i] - left[i] + 1)_{+}  */
            }
            
            /* return pull(work, j - 1, knew - nl)    : */
            knew -= (nl + 1)     /* -1: 0-indexing */
            
            /* sort work array */
            work.sort(by: { $0 < $1})
            return work[Int(knew)]
        }
    }
    
    /*
     gsl_stats_Qn_from_sorted_data()
     Efficient algorithm for the scale estimator:
     
     Q_n = 2.219 * d_n * { |x_i - x_j|; i<j }_(k)
     
     with:
     
     k = (floor(n/2) + 1 choose 2)
     
     and d_n is a correction factor for finite sample bias
     
     Inputs: sorted_data - sorted array containing the observations
     stride      - stride
     n           - length of 'sorted_data'
     work        - workspace of length 3n of type BASE
     work_int    - workspace of length 5n of type int
     
     Return: Q_n statistic
     */
    /// Returns the Qn statisticx by Rousseeuw, P.J. and Croux, C. (1993)
    public var Qn: FPT? {
        get {
            var ex1: FPT
            var ex2: FPT
            var ex3: FPT
            if !self.isNotEmptyAndNumeric {
                return nil
            }
            if let Qn0 = qn0() {
                let scale: FPT =  Helpers.makeFP(2.21914) // as! FPT /* asymptotic consistency for sigma^2 */
                let n = self.sampleSize
                let nn: FPT =  Helpers.makeFP(self.sampleSize)
                var dn: FPT = 1
                var qn: FPT = 0
                
                /* this correction factor deviates from the original paper Croux and Rousseeuw, 1992, and
                 * comes from the 'robustbase' R package */
                if (n <= 12) {
                    if (n == 2) {
                        dn =  Helpers.makeFP(0.399356)
                    }
                    else if (n == 3) {
                        dn =  Helpers.makeFP(0.99365)
                    }
                    else if (n == 4) {
                        dn =  Helpers.makeFP(0.51321)
                    }
                    else if (n == 5) {
                        dn =  Helpers.makeFP(0.84401)
                    }
                    else if (n == 6) {
                        dn =  Helpers.makeFP(0.61220)
                    }
                    else if (n == 7) {
                        dn =  Helpers.makeFP(0.85877)
                    }
                    else if (n == 8) {
                        dn =  Helpers.makeFP(0.66993)
                    }
                    else if (n == 9) {
                        dn =  Helpers.makeFP(0.87344)
                    }
                    else if (n == 10) {
                        dn =  Helpers.makeFP(0.72014)
                    }
                    else if (n == 11) {
                        dn =  Helpers.makeFP(0.88906)
                    }
                    else if (n == 12) {
                        dn =  Helpers.makeFP(0.75743)
                    }
                }
                else {
                    if (n % 2 == 1) { /* n odd */
                        ex1 = Helpers.makeFP(5.172 ) / nn
                        ex2 = Helpers.makeFP(-2.1284) - ex1
                        ex3 = ex2 / nn
                        dn =  Helpers.makeFP(1.60188 ) + ex3
                    }
                    else {            /* n even */
                        let ex1: FPT =  Helpers.makeFP(77.0) / nn
                        let ex2: FPT =  Helpers.makeFP(6.987) - ex1
                        let ex3: FPT =  Helpers.makeFP(1.9654) + ex2 / nn
                        dn =  Helpers.makeFP(3.67561 ) + ex3 / nn
                    }
                
                    dn = 1 / (dn / nn + 1)
                }
                qn = scale * dn * Qn0
                return qn
            }
            else {
                return nil
            }
        }
    }
    
/*
 Algorithm to compute the weighted high median in O(n) time.
 
 The whimed is defined as the smallest a[j] such that the sum
 of the weights of all a[i] <= a[j] is strictly greater than
 half of the total weight.
 
 Arguments:
 
 a: double array containing the observations
 n: number of observations
 w: array of (int/double) weights of the observations.
 */

    fileprivate func qn_whimed(a: inout Array<FPT>, w: inout Array<Int>, n: inout Int, a_cand: inout Array<FPT>, a_srt: inout Array<FPT>, w_cand: inout Array<Int> ) -> FPT {
        var n2, kcand: Int
        /* sum of weights: `int' do overflow when  n ~>= 1e5 */
        var wleft, wmid, wright, w_tot, wrest: Int64
        
        var trial: FPT = FPT.nan
        
        w_tot = 0
        //        for (i = 0; i < n; ++i)
        for i in stride(from: 1, to: n, by: 1) {
            w_tot += Int64(w[i])
        }
        
        wrest = 0
        
        /* REPEAT : */
        //    do
        repeat {
            //        for (i = 0; i < n; ++i)
            for i in stride(from: 0, to: n, by: 1) {
                a_srt[i] = a[i]
            }
            
            n2 = n / 2; /* =^= n/2 +1 with 0-indexing */
            
            a_srt.sort(by: {$0 < $1})
            
            trial = a_srt[n2]
            
            wleft = 0
            wmid = 0
            wright = 0
            
            for i in stride(from: 0, to: n, by: 1) {
                if (a[i] < trial) {
                    wleft += Int64(w[i])
                }
                else if (a[i] > trial) {
                    wright += Int64(w[i])
                }
                else {
                    wmid += Int64(w[i])
                }
            }
            
            /* wleft = sum_{i; a[i]     < trial}  w[i]
             * wmid     = sum_{i; a[i] == trial}  w[i] at least one 'i' since trial is one a[]!
             * wright= sum_{i; a[i]     > trial}  w[i]
             */
            kcand = 0
            if (2 * (wrest + wleft) > w_tot) {
                for i in stride(from: 0, to: n, by: 1) {
                    if (a[i] < trial) {
                        a_cand[kcand] = a[i]
                        w_cand[kcand] = w[i]
                        kcand += 1
                    }
                }
            }
            else if (2 * (wrest + wleft + wmid) <= w_tot) {
                for i in stride(from: 0, to: n, by: 1) {
                    if (a[i] > trial) {
                        a_cand[kcand] = a[i]
                        w_cand[kcand] = w[i]
                        kcand += 1
                    }
                }
                wrest += wleft + wmid
            }
            else {
                return trial
            }
            n = kcand
            for i in stride(from: 0, to: n, by: 1) {
                a[i] = a_cand[i]
                w[i] = w_cand[i]
            }
        } while(true)
    }

}
