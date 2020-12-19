// SPDX-FileCopyrightText: 2020 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: Apache-2.0

import Foundation

#if DEBUG
    let log = Logger()

    struct Logger {
        func info(_ message: String, _ args: Any...) {
            print(message, args)
        }
    }
#endif
