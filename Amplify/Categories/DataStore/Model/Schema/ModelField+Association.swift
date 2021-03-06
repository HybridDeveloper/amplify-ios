//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Defines the association type between two models. The type of association is
/// important when defining how to store and query them. Each association have
/// its own rules depending on the storage mechanism.
///
/// The semantics of a association can be defined as:
///
/// **Many-to-One/One-to-Many**
///
/// The most common association type. It defines an array/collection on one side and a
/// single `Model` reference on the other. The side with the `Model` (marked as `belongsTo`)
/// holds a reference to the other side's `id` (aka "foreign key").
///
/// Example:
///
/// ```
/// struct Post: Model {
///   let id: Model.Identifier
///
///   // hasMany(associatedWith: Comment.keys.post)
///   let comments: [Comment]
/// }
///
/// struct Comment: Model {
///   let id: Model.Identifier
///
///   // belongsTo
///   let post: Post
/// }
/// ```
///
/// **One-to-One**
///
/// This type of association is not too common since in these scenarios data can usually
/// be normalized and stored under the same `Model`. However, there are use-cases where
/// one-to-one can be useful, specially when one side of the association is optional.
///
/// Example:
///
/// ```
/// struct Person: Model {
///   // hasOne(associatedWith: License.keys.person)
///   let license: License?
/// }
///
/// struct License: Model {
///   // belongsTo
///   let person: Person
/// }
/// ```
///
/// **Many-to-Many**
///
/// These associations mean that an instance of one `Model` can relate to many other
/// instances of another `Model` and vice-versa. Many-to-Many is achieved by combining
/// `hasMany` and `belongsTo` with an intermediate `Model` that is responsible for
/// holding a reference to the keys of both related models.
///
/// ```
/// struct Book: Model {
///   // hasMany(associatedWith: BookAuthor.keys.book)
///   let auhors: [BookAuthor]
/// }
///
/// struct Author: Model {
///   // hasMany(associatedWith: BookAuthor.keys.author)
///   let books: [BookAuthor]
/// }
///
/// struct BookAuthor: Model {
///   // belongsTo
///   let book: Book
///
///   // belongsTo
///   let author: Author
/// }
/// ```
///
public enum ModelAssociation {
    case hasMany(associatedWith: CodingKey?)
    case hasOne(associatedWith: CodingKey?)
    case belongsTo(associatedWith: CodingKey?, targetName: String?)

    public static let belongsTo: ModelAssociation = .belongsTo(associatedWith: nil, targetName: nil)

    public static func belongsTo(targetName: String? = nil) -> ModelAssociation {
        return .belongsTo(associatedWith: nil, targetName: nil)
    }

}

extension ModelField {

    public var hasAssociation: Bool {
        return association != nil
    }

    /// If the field represents an association returns the `Model.Type`.
    /// - seealso: `ModelFieldType`
    /// - seealso: `ModelFieldAssociation`
    public var associatedModel: Model.Type? {
        switch type {
        case .model(let type), .collection(let type):
            return type
        default:
            return nil
        }
    }

    /// This calls `associatedModel` but enforces that the field must represent an association.
    /// In case the field type is not a `Model.Type` is calls `preconditionFailure`. Consumers
    /// should fix their models in order to recover from it, since associations are only
    /// possible between two `Model.Type`.
    ///
    /// - Note: as a maintainer, make sure you use this computed property only when context
    /// allows (i.e. the field is a valid relationship, such as foreign keys).
    public var requiredAssociatedModel: Model.Type {
        guard let modelType = associatedModel else {
            preconditionFailure("""
            Model fields that are foreign keys must be connected to another Model.
            Check the `ModelSchema` section of your "\(name)+Schema.swift" file.
            """)
        }
        return modelType
    }

    public var isAssociationOwner: Bool {
        guard case .belongsTo = association else {
            return false
        }
        return true
    }

    public var associatedField: ModelField? {
        if hasAssociation {
            let associatedModel = requiredAssociatedModel
            switch association {
            case .belongsTo(let associatedKey, _):
                // TODO handle modelName casing (convert to camelCase)
                let key = associatedKey?.stringValue ?? associatedModel.modelName
                return associatedModel.schema.field(withName: key)
            case .hasOne(let associatedKey),
                 .hasMany(let associatedKey):
                // TODO handle modelName casing (convert to camelCase)
                let key = associatedKey?.stringValue ?? associatedModel.modelName
                return associatedModel.schema.field(withName: key)
            case .none:
                return nil
            }
        }
        return nil
    }

    public var isOneToOne: Bool {
        if case .hasOne = association {
            return true
        }
        if case .belongsTo = association, case .hasOne = associatedField?.association {
            return true
        }
        return false
    }

    public var isOneToMany: Bool {
        if case .hasMany = association, case .belongsTo = associatedField?.association {
            return true
        }
        return false
    }

    public var isManyToOne: Bool {
        if case .belongsTo = association, case .hasMany = associatedField?.association {
            return true
        }
        return false
    }

}
