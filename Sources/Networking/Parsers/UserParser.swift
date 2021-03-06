////
///  UserParser.swift
//

import SwiftyJSON


class UserParser: IdParser {

    init() {
        super.init(table: .usersType)
        linkObject(.profilesType)
        linkArray(.categoriesType)
        linkArray(.categoryUsersType)
    }

    override func parse(json: JSON) -> User {
        let relationshipPriority = RelationshipPriority(
            stringValue: json["currentUserState"]["relationshipPriority"].string
        )

        let user = User(
            id: json["id"].idValue,
            username: json["username"].stringValue,
            name: json["name"].stringValue,
            relationshipPriority: relationshipPriority,
            postsAdultContent: json["settings"]["postsAdultContent"].boolValue,
            viewsAdultContent: json["settings"]["viewsAdultContent"].boolValue,
            hasCommentingEnabled: json["settings"]["hasCommentingEnabled"].boolValue,
            hasSharingEnabled: json["settings"]["hasSharingEnabled"].boolValue,
            hasRepostingEnabled: json["settings"]["hasRepostingEnabled"].boolValue,
            hasLovesEnabled: json["settings"]["hasLovesEnabled"].boolValue,
            isCollaborateable: json["settings"]["isCollaborateable"].boolValue,
            isHireable: json["settings"]["isHireable"].boolValue
        )

        user.avatar = Asset.parseAsset(
            "user_avatar_\(user.id)",
            node: json["avatar"].dictionaryObject
        )
        user.coverImage = Asset.parseAsset(
            "user_cover_image_\(user.id)",
            node: json["coverImage"].dictionaryObject
        )

        // user.identifiableBy = json["identifiable_by"].string
        user.formattedShortBio = json["formattedShortBio"].string
        // user.onboardingVersion = json["web_onboarding_version"].id.flatMap { Int($0) }
        user.location = json["location"].string

        if let jsonLinks = json["externalLinksList"].array {
            let externalLinks = jsonLinks.compactMap { $0.dictionaryObject as? [String: String] }
            user.externalLinksList = externalLinks.compactMap { ExternalLink.fromDict($0) }
        }

        if let badgeNames:[String] = json["badges"].array?.compactMap({ $0.string }) {
            user.badges =
                badgeNames
                .compactMap { Badge.lookup(slug: $0) }
        }

        user.totalViewsCount = json["userStats"]["totalViewsCount"].int
        user.postsCount = json["userStats"]["postsCount"].int
        user.lovesCount = json["userStats"]["lovesCount"].int
        user.followersCount = json["userStats"]["followersCount"].int
        user.followingCount = json["userStats"]["followingCount"].int

        user.mergeLinks(json["links"].dictionaryObject)

        return user
    }
}
