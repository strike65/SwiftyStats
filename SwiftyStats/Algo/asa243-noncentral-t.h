//
//  Created by VT on 19.07.18.
//  Copyright © 2018 Volker Thieme. All rights reserved.
/*
 Copyright (c) 2017 Volker Thieme
 
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

#ifndef asa243_noncentral_t_h
#define asa243_noncentral_t_h

double alnorm ( double x, int upper );
double betain ( double x, double p, double q, double beta, int *ifault );
void student_noncentral_cdf_values ( int *n_data, int *df, double *lambda,
                                    double *x, double *fx );
void timestamp ( );
double tnc ( double t, double df, double delta, int *ifault );
#endif /* asa243_noncentral_t_h */
