////
///  Stubs.swift
//

@testable import Ello


func stub<T: Stubbable>(_ values: [String: Any]) -> T {
    return T.stub(values)
}

func urlFromValue(_ value: Any?) -> URL? {
    guard let value = value else {
        return nil
    }

    if let url = value as? URL {
        return url
    }
    else if let str = value as? String {
        return URL(string: str)
    }
    return nil
}

func generateID() -> String {
    return UUID().uuidString
}

let stubbedTextRegion: TextRegion = stub([:])

protocol Stubbable: NSObjectProtocol {
    static func stub(_ values: [String: Any]) -> Self
}

extension User: Stubbable {
    class func stub(_ values: [String: Any]) -> User {
        let relationshipPriority: RelationshipPriority
        if let priorityName = values["relationshipPriority"] as? String {
            relationshipPriority = RelationshipPriority(stringValue: priorityName)
        }
        else {
            relationshipPriority = RelationshipPriority.none
        }

        let user = User(
            id: (values["id"] as? String) ?? generateID(),
            username: (values["username"] as? String) ?? "username",
            name: (values["name"] as? String) ?? "name",
            relationshipPriority: relationshipPriority,
            postsAdultContent: (values["postsAdultContent"] as? Bool) ?? false,
            viewsAdultContent: (values["viewsAdultContent"] as? Bool) ?? false,
            hasCommentingEnabled: (values["hasCommentingEnabled"] as? Bool) ?? true,
            hasSharingEnabled: (values["hasSharingEnabled"] as? Bool) ?? true,
            hasRepostingEnabled: (values["hasRepostingEnabled"] as? Bool) ?? true,
            hasLovesEnabled: (values["hasLovesEnabled"] as? Bool) ?? true,
            isCollaborateable: (values["isCollaborateable"] as? Bool) ?? false,
            isHireable: (values["isHireable"] as? Bool) ?? false
        )

        user.coverImage = values["coverImage"] as? Asset
        user.avatar = values["avatar"] as? Asset

        user.experimentalFeatures = values["experimentalFeatures"] as? Bool
        user.identifiableBy = (values["identifiableBy"] as? String)
        user.postsCount = (values["postsCount"] as? Int) ?? 0
        user.lovesCount = (values["lovesCount"] as? Int) ?? 0
        user.totalViewsCount = (values["totalViewsCount"] as? Int)
        user.followingCount = (values["followingCount"] as? Int) ?? 0
        user.formattedShortBio = (values["formattedShortBio"] as? String)
        user.onboardingVersion = (values["onboardingVersion"] as? Int)
        user.location = values["location"] as? String
        user.profile = values["profile"] as? Profile

        if let badges = values["badges"] as? [Badge] {
            user.badges = badges
        }
        else if let badgeNames = values["badges"] as? [String] {
            user.badges = badgeNames.compactMap { Badge.lookup(slug: $0) }
        }

        if let count = values["followersCount"] as? Int {
            user.followersCount = count
        }

        if let linkValues = (values["externalLinksList"] as? [[String: String]]) {
            user.externalLinksList = linkValues.compactMap { ExternalLink.fromDict($0) }
        }
        else if let externalLinks = (values["externalLinksList"] as? [ExternalLink]) {
            user.externalLinksList = externalLinks
        }
        else if let externalLinks = (values["externalLinksList"] as? [String]) {
            user.externalLinksList = externalLinks.map {
                ExternalLink(url: URL(string: $0)!, text: $0)
            }
        }

        if let ids = values["followedCategoryIds"] as? [String] {
            user.followedCategoryIds = Set(ids)
        }

        user.coverImage = values["coverImage"] as? Asset
        user.onboardingVersion = (values["onboardingVersion"] as? Int)
        // links / nested resources
        if let posts = values["posts"] as? [Post] {
            var postIds = [String]()
            for post in posts {
                postIds.append(post.id)
                ElloLinkedStore.shared.setObject(post, forKey: post.id, type: .postsType)
            }
            user.addLinkArray("posts", array: postIds, type: .postsType)
        }

        if let categories = values["categories"] as? [Ello.Category] {
            for category in categories {
                ElloLinkedStore.shared.setObject(
                    category,
                    forKey: category.id,
                    type: .categoriesType
                )
            }
            user.addLinkArray("categories", array: categories.map { $0.id }, type: .categoriesType)
        }

        ElloLinkedStore.shared.setObject(user, forKey: user.id, type: .usersType)

        if (values["hasProfileData"] as? Bool) == true {
            user.postsCount = user.postsCount ?? 0
            user.lovesCount = user.lovesCount ?? 0
            user.followingCount = user.followingCount ?? 0
            user.followersCount = user.followersCount ?? 0
            user.totalViewsCount = user.totalViewsCount ?? 0
        }
        return user
    }
}

extension Username: Stubbable {
    class func stub(_ values: [String: Any]) -> Username {

        let username = Username(
            username: (values["username"] as? String) ?? "archer"
        )

        return username
    }
}

extension Love: Stubbable {
    class func stub(_ values: [String: Any]) -> Love {

        // create necessary links

        let post: Post = (values["post"] as? Post)
            ?? Post.stub(["id": values["postId"] ?? generateID()])
        ElloLinkedStore.shared.setObject(post, forKey: post.id, type: .postsType)

        let user: User = (values["user"] as? User)
            ?? User.stub(["id": values["userId"] ?? generateID()])
        ElloLinkedStore.shared.setObject(user, forKey: user.id, type: .usersType)

        let love = Love(
            id: (values["id"] as? String) ?? generateID(),
            isDeleted: (values["deleted"] as? Bool) ?? true,
            postId: post.id,
            userId: user.id
        )

        return love
    }
}

extension Watch: Stubbable {
    class func stub(_ values: [String: Any]) -> Watch {

        // create necessary links

        let post: Post = (values["post"] as? Post)
            ?? Post.stub(["id": values["postId"] ?? generateID()])
        ElloLinkedStore.shared.setObject(post, forKey: post.id, type: .postsType)

        let user: User = (values["user"] as? User)
            ?? User.stub(["id": values["userId"] ?? generateID()])
        ElloLinkedStore.shared.setObject(user, forKey: user.id, type: .usersType)

        let watch = Watch(
            id: (values["id"] as? String) ?? generateID(),
            postId: post.id,
            userId: user.id
        )

        return watch
    }
}

extension Profile: Stubbable {
    class func stub(_ values: [String: Any]) -> Profile {
        let id = (values["id"] as? String) ?? generateID()
        let createdAt = (values["createdAt"] as? Date) ?? Globals.now
        let shortBio = (values["shortBio"] as? String) ?? "shortBio"
        let email = (values["email"] as? String) ?? "email@example.com"
        let confirmedAt = (values["confirmedAt"] as? Date) ?? Globals.now
        let isPublic = (values["isPublic"] as? Bool) ?? true
        let isCommunity = (values["isCommunity"] as? Bool) ?? false
        let mutedCount = (values["mutedCount"] as? Int) ?? 0
        let blockedCount = (values["blockedCount"] as? Int) ?? 0
        let creatorTypeCategoryIds = (values["creatorTypeCategoryIds"] as? [String]) ?? []
        let moderatedCategoryIds = (values["moderatedCategoryIds"] as? [String]) ?? []
        let curatedCategoryIds = (values["curatedCategoryIds"] as? [String]) ?? []
        let hasSharingEnabled = (values["hasSharingEnabled"] as? Bool) ?? true
        let hasAdNotificationsEnabled = (values["hasAdNotificationsEnabled"] as? Bool) ?? true
        let hasAutoWatchEnabled = (values["hasAutoWatchEnabled"] as? Bool) ?? true
        let allowsAnalytics = (values["allowsAnalytics"] as? Bool) ?? true
        let notifyOfCommentsViaEmail = (values["notifyOfCommentsViaEmail"] as? Bool) ?? true
        let notifyOfLovesViaEmail = (values["notifyOfLovesViaEmail"] as? Bool) ?? true
        let notifyOfInvitationAcceptancesViaEmail = (
            values["notifyOfInvitationAcceptancesViaEmail"] as? Bool
        ) ?? true
        let notifyOfMentionsViaEmail = (values["notifyOfMentionsViaEmail"] as? Bool) ?? true
        let notifyOfNewFollowersViaEmail = (values["notifyOfNewFollowersViaEmail"] as? Bool) ?? true
        let notifyOfRepostsViaEmail = (values["notifyOfRepostsViaEmail"] as? Bool) ?? true
        let notifyOfWhatYouMissedViaEmail = (values["notifyOfWhatYouMissedViaEmail"] as? Bool)
            ?? true
        let notifyOfApprovedSubmissionsFromFollowingViaEmail = (
            values["notifyOfApprovedSubmissionsFromFollowingViaEmail"] as? Bool
        ) ?? true
        let notifyOfFeaturedCategoryPostViaEmail = (
            values["notifyOfFeaturedCategoryPostViaEmail"] as? Bool
        ) ?? true
        let notifyOfFeaturedCategoryPostViaPush = (
            values["notifyOfFeaturedCategoryPostViaPush"] as? Bool
        ) ?? true
        let subscribeToUsersEmailList = (values["subscribeToUsersEmailList"] as? Bool) ?? true
        let subscribeToDailyEllo = (values["subscribeToDailyEllo"] as? Bool) ?? true
        let subscribeToWeeklyEllo = (values["subscribeToWeeklyEllo"] as? Bool) ?? true
        let subscribeToOnboardingDrip = (values["subscribeToOnboardingDrip"] as? Bool) ?? true
        let notifyOfAnnouncementsViaPush = (values["notifyOfAnnouncementsViaPush"] as? Bool) ?? true
        let notifyOfApprovedSubmissionsViaPush = (
            values["notifyOfApprovedSubmissionsViaPush"] as? Bool
        ) ?? true
        let notifyOfCommentsViaPush = (values["notifyOfCommentsViaPush"] as? Bool) ?? true
        let notifyOfLovesViaPush = (values["notifyOfLovesViaPush"] as? Bool) ?? true
        let notifyOfMentionsViaPush = (values["notifyOfMentionsViaPush"] as? Bool) ?? true
        let notifyOfRepostsViaPush = (values["notifyOfRepostsViaPush"] as? Bool) ?? true
        let notifyOfNewFollowersViaPush = (values["notifyOfNewFollowersViaPush"] as? Bool) ?? true
        let notifyOfInvitationAcceptancesViaPush = (
            values["notifyOfInvitationAcceptancesViaPush"] as? Bool
        ) ?? true
        let notifyOfWatchesViaPush = (values["notifyOfWatchesViaPush"] as? Bool) ?? true
        let notifyOfWatchesViaEmail = (values["notifyOfWatchesViaEmail"] as? Bool) ?? true
        let notifyOfCommentsOnPostWatchViaPush = (
            values["notifyOfCommentsOnPostWatchViaPush"] as? Bool
        ) ?? true
        let notifyOfCommentsOnPostWatchViaEmail = (
            values["notifyOfCommentsOnPostWatchViaEmail"] as? Bool
        ) ?? true
        let notifyOfApprovedSubmissionsFromFollowingViaPush = (
            values["notifyOfApprovedSubmissionsFromFollowingViaPush"] as? Bool
        ) ?? true
        let hasAnnouncementsEnabled = (values["hasAnnouncementsEnabled"] as? Bool) ?? true
        let discoverable = (values["discoverable"] as? Bool) ?? true
        let gaUniqueId = values["gaUniqueId"] as? String

        let profile = Profile(
            id: id,
            createdAt: createdAt,
            shortBio: shortBio,
            email: email,
            confirmedAt: confirmedAt,
            isPublic: isPublic,
            isCommunity: isCommunity,
            mutedCount: mutedCount,
            blockedCount: blockedCount,
            creatorTypeCategoryIds: creatorTypeCategoryIds,
            moderatedCategoryIds: moderatedCategoryIds,
            curatedCategoryIds: curatedCategoryIds,
            hasSharingEnabled: hasSharingEnabled,
            hasAdNotificationsEnabled: hasAdNotificationsEnabled,
            hasAutoWatchEnabled: hasAutoWatchEnabled,
            allowsAnalytics: allowsAnalytics,
            notifyOfCommentsViaEmail: notifyOfCommentsViaEmail,
            notifyOfLovesViaEmail: notifyOfLovesViaEmail,
            notifyOfInvitationAcceptancesViaEmail: notifyOfInvitationAcceptancesViaEmail,
            notifyOfMentionsViaEmail: notifyOfMentionsViaEmail,
            notifyOfNewFollowersViaEmail: notifyOfNewFollowersViaEmail,
            notifyOfRepostsViaEmail: notifyOfRepostsViaEmail,
            notifyOfWhatYouMissedViaEmail: notifyOfWhatYouMissedViaEmail,
            notifyOfApprovedSubmissionsFromFollowingViaEmail:
                notifyOfApprovedSubmissionsFromFollowingViaEmail,
            notifyOfFeaturedCategoryPostViaEmail: notifyOfFeaturedCategoryPostViaEmail,
            notifyOfFeaturedCategoryPostViaPush: notifyOfFeaturedCategoryPostViaPush,
            subscribeToUsersEmailList: subscribeToUsersEmailList,
            subscribeToDailyEllo: subscribeToDailyEllo,
            subscribeToWeeklyEllo: subscribeToWeeklyEllo,
            subscribeToOnboardingDrip: subscribeToOnboardingDrip,
            notifyOfAnnouncementsViaPush: notifyOfAnnouncementsViaPush,
            notifyOfApprovedSubmissionsViaPush: notifyOfApprovedSubmissionsViaPush,
            notifyOfCommentsViaPush: notifyOfCommentsViaPush,
            notifyOfLovesViaPush: notifyOfLovesViaPush,
            notifyOfMentionsViaPush: notifyOfMentionsViaPush,
            notifyOfRepostsViaPush: notifyOfRepostsViaPush,
            notifyOfNewFollowersViaPush: notifyOfNewFollowersViaPush,
            notifyOfInvitationAcceptancesViaPush: notifyOfInvitationAcceptancesViaPush,
            notifyOfWatchesViaPush: notifyOfWatchesViaPush,
            notifyOfWatchesViaEmail: notifyOfWatchesViaEmail,
            notifyOfCommentsOnPostWatchViaPush: notifyOfCommentsOnPostWatchViaPush,
            notifyOfCommentsOnPostWatchViaEmail: notifyOfCommentsOnPostWatchViaEmail,
            notifyOfApprovedSubmissionsFromFollowingViaPush:
                notifyOfApprovedSubmissionsFromFollowingViaPush,
            hasAnnouncementsEnabled: hasAnnouncementsEnabled,
            discoverable: discoverable,
            gaUniqueId: gaUniqueId
        )
        return profile
    }
}

extension Post: Stubbable {
    class func stub(_ values: [String: Any]) -> Post {

        // create necessary links

        let author: User = (values["author"] as? User)
            ?? User.stub(["id": values["authorId"] ?? generateID()])
        ElloLinkedStore.shared.setObject(author, forKey: author.id, type: .usersType)

        let post = Post(
            id: (values["id"] as? String) ?? generateID(),
            createdAt: (values["createdAt"] as? Date) ?? Globals.now,
            authorId: author.id,
            token: (values["token"] as? String) ?? "sample-token",
            isAdultContent: (values["isAdultContent"] as? Bool) ?? false,
            contentWarning: (values["contentWarning"] as? String) ?? "",
            allowComments: (values["allowComments"] as? Bool) ?? false,
            isReposted: (values["reposted"] as? Bool) ?? false,
            isLoved: (values["loved"] as? Bool) ?? false,
            isWatching: (values["watching"] as? Bool) ?? false,
            summary: (values["summary"] as? [Regionable]) ?? [stubbedTextRegion],
            content: (values["content"] as? [Regionable]) ?? [stubbedTextRegion],
            body: (values["body"] as? [Regionable]) ?? [stubbedTextRegion],
            repostContent: (values["repostContent"] as? [Regionable]) ?? []
        )

        let repostAuthor: User? = values["repostAuthor"] as? User
            ?? (values["repostAuthorId"] as? String).flatMap { id in
                return User.stub(["id": id])
            }

        if let repostAuthor = repostAuthor {
            ElloLinkedStore.shared.setObject(
                repostAuthor,
                forKey: repostAuthor.id,
                type: .usersType
            )
            post.storeLinkObject(
                repostAuthor,
                key: "repost_author",
                id: repostAuthor.id,
                type: .usersType
            )
        }

        if let category = values["category"] as? Ello.Category {
            ElloLinkedStore.shared.setObject(category, forKey: category.id, type: .categoriesType)
            post.addLinkObject("category", id: category.id, type: .categoriesType)
        }
        else if let categories = values["categories"] as? [Ello.Category] {
            for category in categories {
                ElloLinkedStore.shared.setObject(
                    category,
                    forKey: category.id,
                    type: .categoriesType
                )
                post.addLinkObject("category", id: category.id, type: .categoriesType)
            }
            post.addLinkArray("categories", array: categories.map { $0.id }, type: .categoriesType)
        }

        post.artistInviteId = (values["artistInviteId"] as? String)
        post.viewsCount = values["viewsCount"] as? Int
        post.commentsCount = values["commentsCount"] as? Int
        post.repostsCount = values["repostsCount"] as? Int
        post.lovesCount = values["lovesCount"] as? Int
        // links / nested resources
        if let assets = values["assets"] as? [Asset] {
            var assetIds = [String]()
            for asset in assets {
                assetIds.append(asset.id)
                ElloLinkedStore.shared.setObject(asset, forKey: asset.id, type: .assetsType)
            }
            post.addLinkArray("assets", array: assetIds, type: .assetsType)
        }
        if let comments = values["comments"] as? [ElloComment] {
            var commentIds = [String]()
            for comment in comments {
                commentIds.append(comment.id)
                ElloLinkedStore.shared.setObject(comment, forKey: comment.id, type: .commentsType)
            }
            post.addLinkArray("comments", array: commentIds, type: .commentsType)
        }
        ElloLinkedStore.shared.setObject(post, forKey: post.id, type: .postsType)
        return post
    }

    class func stubWithRegions(
        _ values: [String: Any],
        summary: [Regionable] = [],
        content: [Regionable] = []
    ) -> Post {
        var mutatedValues = values
        mutatedValues.updateValue(summary, forKey: "summary")
        let post: Post = stub(mutatedValues)
        post.content = content
        return post
    }

}

extension ElloComment: Stubbable {
    class func stub(_ values: [String: Any]) -> ElloComment {

        // create necessary links
        let author: User = (values["author"] as? User)
            ?? User.stub(["id": values["authorId"] ?? generateID()])
        ElloLinkedStore.shared.setObject(author, forKey: author.id, type: .usersType)
        let parentPost: Post = (values["parentPost"] as? Post)
            ?? Post.stub(["id": values["parentPostId"] ?? generateID()])
        ElloLinkedStore.shared.setObject(parentPost, forKey: parentPost.id, type: .postsType)
        let loadedFromPost: Post = (values["loadedFromPost"] as? Post) ?? parentPost
        ElloLinkedStore.shared.setObject(
            loadedFromPost,
            forKey: loadedFromPost.id,
            type: .postsType
        )

        let comment = ElloComment(
            id: (values["id"] as? String) ?? generateID(),
            createdAt: (values["createdAt"] as? Date) ?? Globals.now,
            authorId: author.id,
            postId: parentPost.id,
            content: (values["content"] as? [Regionable]) ?? [stubbedTextRegion],
            body: (values["body"] as? [Regionable]) ?? [stubbedTextRegion],
            summary: (values["summary"] as? [Regionable]) ?? [stubbedTextRegion]
        )

        comment.loadedFromPostId = loadedFromPost.id

        if let assets = values["assets"] as? [Asset] {
            var assetIds = [String]()
            for asset in assets {
                assetIds.append(asset.id)
                ElloLinkedStore.shared.setObject(asset, forKey: asset.id, type: .assetsType)
            }
            comment.addLinkArray("assets", array: assetIds, type: .assetsType)
        }
        ElloLinkedStore.shared.setObject(comment, forKey: comment.id, type: .commentsType)
        return comment
    }
}

extension TextRegion: Stubbable {
    class func stub(_ values: [String: Any]) -> TextRegion {
        return TextRegion(
            content: (values["content"] as? String) ?? "<p>Lorem Ipsum</p>"
        )
    }
}

extension ImageRegion: Stubbable {
    class func stub(_ values: [String: Any]) -> ImageRegion {
        let imageRegion = ImageRegion(
            url: urlFromValue(values["url"]),
            buyButtonURL: urlFromValue(values["buyButtonURL"])
        )
        if let asset = values["asset"] as? Asset {
            imageRegion.storeLinkObject(asset, key: "assets", id: asset.id, type: .assetsType)
        }
        return imageRegion
    }
}

extension EmbedRegion: Stubbable {
    class func stub(_ values: [String: Any]) -> EmbedRegion {
        let serviceString = (values["service"] as? String) ?? Service.youtube.rawValue
        let embedRegion = EmbedRegion(
            id: (values["id"] as? String) ?? generateID(),
            service: Service(rawValue: serviceString)!,
            url: urlFromValue(values["url"]) ?? URL(string: "http://www.google.com")!,
            thumbnailLargeUrl: urlFromValue(values["thumbnailLargeUrl"])
        )
        embedRegion.isRepost = (values["isRepost"] as? Bool) ?? false
        return embedRegion
    }
}

extension AutoCompleteResult: Stubbable {
    class func stub(_ values: [String: Any]) -> AutoCompleteResult {
        let name = (values["name"] as? String) ?? "666"
        let result = AutoCompleteResult(name: name)
        result.url = urlFromValue(values["url"]) ?? URL(string: "http://www.google.com")!
        return result
    }
}

extension Activity: Stubbable {

    class func stub(_ values: [String: Any]) -> Activity {
        let activityKind: Activity.Kind
        if let kind = values["kind"] as? Activity.Kind {
            activityKind = kind
        }
        else if let kindString = values["kind"] as? String,
            let kind = Activity.Kind(rawValue: kindString)
        {
            activityKind = kind
        }
        else {
            activityKind = .newFollowerPost
        }

        let activitySubjectType: SubjectType
        if let type = values["subjectType"] as? SubjectType {
            activitySubjectType = type
        }
        else if let subjectTypeString = values["subjectType"] as? String,
            let type = SubjectType(rawValue: subjectTypeString)
        {
            activitySubjectType = type
        }
        else {
            activitySubjectType = .post
        }

        let activity = Activity(
            id: (values["id"] as? String) ?? generateID(),
            createdAt: (values["createdAt"] as? Date) ?? Globals.now,
            kind: activityKind,
            subjectType: activitySubjectType
        )

        if let user = values["subject"] as? User {
            ElloLinkedStore.shared.setObject(user, forKey: user.id, type: .usersType)
            activity.storeLinkObject(user, key: "subject", id: user.id, type: .usersType)
        }
        else if let post = values["subject"] as? Post {
            ElloLinkedStore.shared.setObject(post, forKey: post.id, type: .postsType)
            activity.storeLinkObject(post, key: "subject", id: post.id, type: .postsType)
        }
        else if let comment = values["subject"] as? ElloComment {
            ElloLinkedStore.shared.setObject(comment, forKey: comment.id, type: .commentsType)
            activity.storeLinkObject(comment, key: "subject", id: comment.id, type: .commentsType)
        }
        ElloLinkedStore.shared.setObject(activity, forKey: activity.id, type: .activitiesType)
        return activity
    }
}

extension Asset: Stubbable {
    class func stub(_ values: [String: Any]) -> Asset {
        if let url = values["url"] as? String {
            return Asset(url: URL(string: url)!)
        }
        else if let url = values["url"] as? URL {
            return Asset(url: url)
        }

        let asset = Asset(id: (values["id"] as? String) ?? generateID())
        let defaultAttachment = values["attachment"] as? Attachment
        asset.optimized = (values["optimized"] as? Attachment) ?? defaultAttachment
        asset.mdpi = (values["mdpi"] as? Attachment) ?? defaultAttachment
        asset.hdpi = (values["hdpi"] as? Attachment) ?? defaultAttachment
        asset.xhdpi = (values["xhdpi"] as? Attachment) ?? defaultAttachment
        asset.original = (values["original"] as? Attachment) ?? defaultAttachment
        asset.large = (values["large"] as? Attachment) ?? defaultAttachment
        asset.regular = (values["regular"] as? Attachment) ?? defaultAttachment
        ElloLinkedStore.shared.setObject(asset, forKey: asset.id, type: .assetsType)
        return asset
    }
}

extension Attachment: Stubbable {
    class func stub(_ values: [String: Any]) -> Attachment {
        let attachment = Attachment(
            url: urlFromValue(values["url"]) ?? URL(string: "http://www.google.com")!
        )
        attachment.height = values["height"] as? Int
        attachment.width = values["width"] as? Int
        attachment.type = values["type"] as? String
        attachment.size = values["size"] as? Int
        attachment.image = values["image"] as? UIImage
        return attachment
    }
}

extension Ello.Notification: Stubbable {
    class func stub(_ values: [String: Any]) -> Ello.Notification {
        return Notification(activity: (values["activity"] as? Activity) ?? Activity.stub([:]))
    }
}

extension Relationship: Stubbable {
    class func stub(_ values: [String: Any]) -> Relationship {
        // create necessary links
        let owner: User = (values["owner"] as? User)
            ?? User.stub(["relationshipPriority": "self", "id": values["ownerId"] ?? generateID()])
        ElloLinkedStore.shared.setObject(owner, forKey: owner.id, type: .usersType)
        let subject: User = (values["subject"] as? User)
            ?? User.stub([
                "relationshipPriority": "friend", "id": values["subjectId"] ?? generateID()
            ])
        ElloLinkedStore.shared.setObject(owner, forKey: owner.id, type: .usersType)
        return Relationship(ownerId: owner.id, subjectId: subject.id)
    }
}

extension LocalPerson: Stubbable {
    class func stub(_ values: [String: Any]) -> LocalPerson {
        return LocalPerson(
            name: (values["name"] as? String) ?? "Sterling Archer",
            emails: (values["emails"] as? [String]) ?? ["sterling_archer@gmail.com"],
            id: (values["id"] as? String) ?? generateID()
        )
    }
}

extension StreamCellItem: Stubbable {
    class func stub(_ values: [String: Any]) -> StreamCellItem {
        return StreamCellItem(
            jsonable: (values["jsonable"] as? Model) ?? Post.stub([:]),
            type: (values["type"] as? StreamCellType) ?? .streamHeader
        )
    }
}

extension PageHeader: Stubbable {
    class func stub(_ values: [String: Any]) -> PageHeader {
        let id = (values["id"] as? String) ?? generateID()
        let postToken = (values["postToken"] as? String)
        let categoryId = (values["categoryId"] as? String)
        let header = (values["header"] as? String) ?? "Default Header"
        let subheader = (values["subheader"] as? String) ?? "Default Subheader"
        let ctaCaption = (values["ctaCaption"] as? String) ?? "Default CTA Caption"
        let ctaURL = urlFromValue(values["ctaURL"])
        let isSponsored = (values["isSponsored"] as? Bool) ?? false
        let image = values["image"] as? Asset
        let kind = (values["kind"] as? PageHeader.Kind) ?? .generic

        let pageHeader = PageHeader(
            id: id,
            postToken: postToken,
            categoryId: categoryId,
            header: header,
            subheader: subheader,
            ctaCaption: ctaCaption,
            ctaURL: ctaURL,
            isSponsored: isSponsored,
            image: image,
            kind: kind
        )

        if let user = values["user"] as? User {
            pageHeader.storeLinkObject(user, key: "user", id: user.id, type: .usersType)
        }

        return pageHeader
    }
}

extension Ello.Category: Stubbable {
    class func stub(_ values: [String: Any]) -> Ello.Category {
        let id = (values["id"] as? String) ?? generateID()
        let name = (values["name"] as? String) ?? "Art"
        let slug = (values["slug"] as? String) ?? "art"
        let description = (values["description"] as? String) ?? ""
        let order = (values["order"] as? Int) ?? 0
        let allowInOnboarding = (values["allowInOnboarding"] as? Bool) ?? true
        let isCreatorType = (values["isCreatorType"] as? Bool) ?? true

        let tileImage: Attachment?
        if let json = values["tileImage"] as? [String: Any] {
            tileImage = Attachment.fromJSON(json)
        }
        else {
            tileImage = nil
        }

        let level: CategoryLevel
        if let levelAsString = values["level"] as? String,
            let rawLevel = CategoryLevel(rawValue: levelAsString)
        {
            level = rawLevel
        }
        else {
            level = .primary
        }

        let category = Category(
            id: id,
            name: name,
            slug: slug,
            description: description,
            order: order,
            allowInOnboarding: allowInOnboarding,
            isCreatorType: isCreatorType,
            level: level,
            tileImage: tileImage
        )

        return category
    }
}

extension Announcement: Stubbable {
    class func stub(_ values: [String: Any]) -> Announcement {
        let image: Asset
        if let _image = values["image"] as? Asset {
            image = _image
        }
        else if let imageValues = values["image"] as? [String: Any] {
            image = Asset.stub(imageValues)
        }
        else {
            image = Asset(url: URL(string: "http://media.colinta.com/minime.png")!)
        }

        let announcement = Announcement(
            id: (values["id"] as? String) ?? generateID(),
            isStaffPreview: (values["isStaffPreview"] as? Bool) ?? false,
            header: (values["header"] as? String)
                ?? "Announcing Not For Print, Ello’s new publication",
            body: (values["body"] as? String)
                ?? "Submissions for Issue 01 — Censorship will be open from 11/7 – 11/23",
            ctaURL: urlFromValue(values["ctaURL"]),
            ctaCaption: (values["ctaCaption"] as? String) ?? "Learn More",
            image: image
        )

        return announcement
    }
}

extension Editorial: Stubbable {

    class func stub(_ values: [String: Any]) -> Editorial {
        let kind = Editorial.Kind(rawValue: values["kind"] as? String ?? "unknown")!
        let postStreamURL: URL? = (values["postStreamURL"] as? URL)
            ?? (values["postStreamURL"] as? String).flatMap { URL(string: $0) }
        let url: URL? = (values["url"] as? URL)
            ?? (values["url"] as? String).flatMap { URL(string: $0) }

        let editorial = Editorial(
            id: (values["id"] as? String) ?? generateID(),
            kind: kind,
            title: (values["title"] as? String) ?? "Title",
            subtitle: values["subtitle"] as? String,
            postStreamURL: postStreamURL,
            url: url
        )
        if let posts = values["posts"] as? [Post] {
            editorial.posts = posts
        }

        if let post = values["post"] as? Post {
            ElloLinkedStore.shared.setObject(post, forKey: post.id, type: .postsType)
            editorial.addLinkObject("post", id: post.id, type: .postsType)
        }
        return editorial
    }
}

extension Badge: Stubbable {

    class func stub(_ values: [String: Any]) -> Badge {
        let badge = Badge(
            slug: (values["slug"] as? String) ?? "featured",
            name: (values["name"] as? String) ?? "Featured",
            caption: (values["caption"] as? String) ?? "Featured",
            url: urlFromValue(values["url"]),
            imageURL: urlFromValue(values["imageURL"])
        )
        return badge
    }
}
