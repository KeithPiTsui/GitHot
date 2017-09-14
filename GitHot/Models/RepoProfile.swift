//
//  RepoProfile.swift
//  GitHot
//
//  Created by Pi on 23/08/2017.
//  Copyright © 2017 Keith. All rights reserved.
//

import PaversFRP

struct RepoProfile {
  let ownerName: String
  let repoName: String
  let repoDesc: String
  let plName: String
  let allStars: UInt
  let periodStars: UInt
  let forks: UInt
}

extension RepoProfile {
  enum lens {
    static let ownerName = Lens<RepoProfile, String> (
      view:{$0.ownerName},
      set: {.init(ownerName: $0,
                  repoName:$1.repoName,
                  repoDesc: $1.repoDesc,
                  plName: $1.plName,
                  allStars: $1.allStars,
                  periodStars: $1.periodStars,
                  forks: $1.forks)}
    )
    static let repoName = Lens<RepoProfile, String> (
      view:{$0.repoName},
      set: {.init(ownerName: $1.ownerName,
                  repoName:$0,
                  repoDesc: $1.repoDesc,
                  plName: $1.plName,
                  allStars: $1.allStars,
                  periodStars: $1.periodStars,
                  forks: $1.forks)}
    )
    static let repoDesc = Lens<RepoProfile, String> (
      view:{$0.repoDesc},
      set: {.init(ownerName: $1.ownerName,
                  repoName:$1.repoName,
                  repoDesc: $0,
                  plName: $1.plName,
                  allStars: $1.allStars,
                  periodStars: $1.periodStars,
                  forks: $1.forks)}
    )
    static let plName = Lens<RepoProfile, String> (
      view:{$0.plName},
      set: {.init(ownerName: $1.ownerName,
                  repoName:$1.repoName,
                  repoDesc: $1.repoDesc,
                  plName: $0,
                  allStars: $1.allStars,
                  periodStars: $1.periodStars,
                  forks: $1.forks)}
    )
    static let allStars = Lens<RepoProfile, UInt> (
      view:{$0.allStars},
      set: {.init(ownerName: $1.ownerName,
                  repoName:$1.repoName,
                  repoDesc: $1.repoDesc,
                  plName: $1.plName,
                  allStars: $0,
                  periodStars: $1.periodStars,
                  forks: $1.forks)}
    )
    static let periodStars = Lens<RepoProfile, UInt> (
      view:{$0.periodStars},
      set: {.init(ownerName: $1.ownerName,
                  repoName:$1.repoName,
                  repoDesc: $1.repoDesc,
                  plName: $1.plName,
                  allStars: $1.allStars,
                  periodStars: $0,
                  forks: $1.forks)}
    )
    static let forks = Lens<RepoProfile, UInt> (
      view:{$0.forks},
      set: {.init(ownerName: $1.ownerName,
                  repoName:$1.repoName,
                  repoDesc: $1.repoDesc,
                  plName: $1.plName,
                  allStars: $1.allStars,
                  periodStars: $1.periodStars,
                  forks: $0)}
    )
  }
}

extension RepoProfile {
  static let example = RepoProfile(ownerName: "madebybowtie", repoName: "FlagKit", repoDesc: "Beautiful flag icons for usage in apps and on the web, Beautiful flag icons for usage in apps and on the web, Beautiful flag icons for usage in apps and on the web", plName: "Swift", allStars: 1662, periodStars: 20, forks: 107)
}




