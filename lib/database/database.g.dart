// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DecryptedEventItemsTable extends DecryptedEventItems
    with TableInfo<$DecryptedEventItemsTable, DecryptedEventItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecryptedEventItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decrypted_event_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DecryptedEventItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  DecryptedEventItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DecryptedEventItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $DecryptedEventItemsTable createAlias(String alias) {
    return $DecryptedEventItemsTable(attachedDatabase, alias);
  }
}

class DecryptedEventItem extends DataClass
    implements Insertable<DecryptedEventItem> {
  final String id;
  final String content;
  const DecryptedEventItem({required this.id, required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content'] = Variable<String>(content);
    return map;
  }

  DecryptedEventItemsCompanion toCompanion(bool nullToAbsent) {
    return DecryptedEventItemsCompanion(id: Value(id), content: Value(content));
  }

  factory DecryptedEventItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DecryptedEventItem(
      id: serializer.fromJson<String>(json['id']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'content': serializer.toJson<String>(content),
    };
  }

  DecryptedEventItem copyWith({String? id, String? content}) =>
      DecryptedEventItem(id: id ?? this.id, content: content ?? this.content);
  DecryptedEventItem copyWithCompanion(DecryptedEventItemsCompanion data) {
    return DecryptedEventItem(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DecryptedEventItem(')
          ..write('id: $id, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DecryptedEventItem &&
          other.id == this.id &&
          other.content == this.content);
}

class DecryptedEventItemsCompanion extends UpdateCompanion<DecryptedEventItem> {
  final Value<String> id;
  final Value<String> content;
  final Value<int> rowid;
  const DecryptedEventItemsCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecryptedEventItemsCompanion.insert({
    required String id,
    required String content,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       content = Value(content);
  static Insertable<DecryptedEventItem> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecryptedEventItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? content,
    Value<int>? rowid,
  }) {
    return DecryptedEventItemsCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecryptedEventItemsCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DecryptedEventItemsTable decryptedEventItems =
      $DecryptedEventItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [decryptedEventItems];
}

typedef $$DecryptedEventItemsTableCreateCompanionBuilder =
    DecryptedEventItemsCompanion Function({
      required String id,
      required String content,
      Value<int> rowid,
    });
typedef $$DecryptedEventItemsTableUpdateCompanionBuilder =
    DecryptedEventItemsCompanion Function({
      Value<String> id,
      Value<String> content,
      Value<int> rowid,
    });

class $$DecryptedEventItemsTableFilterComposer
    extends Composer<_$AppDatabase, $DecryptedEventItemsTable> {
  $$DecryptedEventItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DecryptedEventItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $DecryptedEventItemsTable> {
  $$DecryptedEventItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DecryptedEventItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DecryptedEventItemsTable> {
  $$DecryptedEventItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$DecryptedEventItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DecryptedEventItemsTable,
          DecryptedEventItem,
          $$DecryptedEventItemsTableFilterComposer,
          $$DecryptedEventItemsTableOrderingComposer,
          $$DecryptedEventItemsTableAnnotationComposer,
          $$DecryptedEventItemsTableCreateCompanionBuilder,
          $$DecryptedEventItemsTableUpdateCompanionBuilder,
          (
            DecryptedEventItem,
            BaseReferences<
              _$AppDatabase,
              $DecryptedEventItemsTable,
              DecryptedEventItem
            >,
          ),
          DecryptedEventItem,
          PrefetchHooks Function()
        > {
  $$DecryptedEventItemsTableTableManager(
    _$AppDatabase db,
    $DecryptedEventItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecryptedEventItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecryptedEventItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DecryptedEventItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecryptedEventItemsCompanion(
                id: id,
                content: content,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String content,
                Value<int> rowid = const Value.absent(),
              }) => DecryptedEventItemsCompanion.insert(
                id: id,
                content: content,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DecryptedEventItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DecryptedEventItemsTable,
      DecryptedEventItem,
      $$DecryptedEventItemsTableFilterComposer,
      $$DecryptedEventItemsTableOrderingComposer,
      $$DecryptedEventItemsTableAnnotationComposer,
      $$DecryptedEventItemsTableCreateCompanionBuilder,
      $$DecryptedEventItemsTableUpdateCompanionBuilder,
      (
        DecryptedEventItem,
        BaseReferences<
          _$AppDatabase,
          $DecryptedEventItemsTable,
          DecryptedEventItem
        >,
      ),
      DecryptedEventItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DecryptedEventItemsTableTableManager get decryptedEventItems =>
      $$DecryptedEventItemsTableTableManager(_db, _db.decryptedEventItems);
}
