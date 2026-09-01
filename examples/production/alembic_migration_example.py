"""Alembic migration pattern: reversible, additive, never edits released migrations.

Revision ID: 0001_create_users
"""

from alembic import op
import sqlalchemy as sa

revision = "0001_create_users"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.BigInteger, primary_key=True),
        sa.Column("username", sa.String(64), nullable=False, unique=True),
        sa.Column("email", sa.String(255), nullable=False),
        sa.Column("password_hash", sa.String(255), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
    )
    # Indexes ship with the schema change that needs them.
    op.create_index("ix_users_email", "users", ["email"])


def downgrade() -> None:
    # Every migration must be reversible.
    op.drop_index("ix_users_email", table_name="users")
    op.drop_table("users")
