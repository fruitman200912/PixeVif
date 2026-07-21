-- CreateEnum
CREATE TYPE "auth_provider" AS ENUM ('local', 'google');

-- CreateEnum
CREATE TYPE "user_plan" AS ENUM ('free', 'pro', 'team');

-- CreateEnum
CREATE TYPE "project_style" AS ENUM ('rpg', 'platformer', 'topdown', 'custom');

-- CreateEnum
CREATE TYPE "member_role" AS ENUM ('owner', 'editor', 'viewer');

-- CreateEnum
CREATE TYPE "ai_status" AS ENUM ('queued', 'processing', 'completed', 'failed');

-- CreateEnum
CREATE TYPE "ai_target" AS ENUM ('new_layer', 'overwrite');

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "password_hash" VARCHAR(255),
    "username" VARCHAR(20) NOT NULL,
    "provider" "auth_provider" NOT NULL DEFAULT 'local',
    "provider_id" VARCHAR(255),
    "plan" "user_plan" NOT NULL DEFAULT 'free',
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "refresh_tokens" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "token_hash" VARCHAR(255) NOT NULL,
    "expires_at" TIMESTAMPTZ NOT NULL,
    "revoked" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "projects" (
    "id" UUID NOT NULL,
    "title" VARCHAR(50) NOT NULL,
    "owner_id" UUID NOT NULL,
    "width" INTEGER NOT NULL,
    "height" INTEGER NOT NULL,
    "style" "project_style" NOT NULL DEFAULT 'custom',
    "color_limit" INTEGER NOT NULL DEFAULT 16,
    "palette" JSONB,
    "is_public" BOOLEAN NOT NULL DEFAULT false,
    "views" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "projects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_members" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "role" "member_role" NOT NULL DEFAULT 'viewer',
    "joined_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "project_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "layers" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "name" VARCHAR(50) NOT NULL DEFAULT 'Layer',
    "order_index" INTEGER NOT NULL DEFAULT 0,
    "visible" BOOLEAN NOT NULL DEFAULT true,
    "opacity" INTEGER NOT NULL DEFAULT 100,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "layers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "canvas_states" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "layer_id" UUID NOT NULL,
    "data" BYTEA NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "canvas_states_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ai_generations" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "prompt" TEXT NOT NULL,
    "final_prompt" TEXT,
    "target" "ai_target" NOT NULL DEFAULT 'new_layer',
    "status" "ai_status" NOT NULL DEFAULT 'queued',
    "result_url" VARCHAR(500),
    "cache_key" VARCHAR(255),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ai_generations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invites" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "token" VARCHAR(64) NOT NULL,
    "role" "member_role" NOT NULL DEFAULT 'editor',
    "created_by" UUID NOT NULL,
    "expires_at" TIMESTAMPTZ NOT NULL,
    "one_time" BOOLEAN NOT NULL DEFAULT false,
    "used" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "invites_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tags" (
    "id" UUID NOT NULL,
    "name" VARCHAR(30) NOT NULL,

    CONSTRAINT "tags_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_tags" (
    "project_id" UUID NOT NULL,
    "tag_id" UUID NOT NULL,

    CONSTRAINT "project_tags_pkey" PRIMARY KEY ("project_id","tag_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE UNIQUE INDEX "idx_users_provider" ON "users"("provider", "provider_id");

-- CreateIndex
CREATE UNIQUE INDEX "refresh_tokens_token_hash_key" ON "refresh_tokens"("token_hash");

-- CreateIndex
CREATE INDEX "idx_refresh_user" ON "refresh_tokens"("user_id");

-- CreateIndex
CREATE INDEX "idx_refresh_expires" ON "refresh_tokens"("expires_at");

-- CreateIndex
CREATE INDEX "idx_projects_owner" ON "projects"("owner_id");

-- CreateIndex
CREATE INDEX "idx_projects_public_recent" ON "projects"("is_public", "created_at" DESC);

-- CreateIndex
CREATE INDEX "idx_projects_public_views" ON "projects"("is_public", "views" DESC);

-- CreateIndex
CREATE INDEX "idx_members_user" ON "project_members"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "project_members_project_id_user_id_key" ON "project_members"("project_id", "user_id");

-- CreateIndex
CREATE INDEX "idx_layers_project" ON "layers"("project_id", "order_index");

-- CreateIndex
CREATE UNIQUE INDEX "canvas_states_project_id_layer_id_key" ON "canvas_states"("project_id", "layer_id");

-- CreateIndex
CREATE INDEX "idx_ai_user_created" ON "ai_generations"("user_id", "created_at" DESC);

-- CreateIndex
CREATE INDEX "idx_ai_cache" ON "ai_generations"("cache_key");

-- CreateIndex
CREATE UNIQUE INDEX "invites_token_key" ON "invites"("token");

-- CreateIndex
CREATE INDEX "idx_invites_project" ON "invites"("project_id");

-- CreateIndex
CREATE UNIQUE INDEX "tags_name_key" ON "tags"("name");

-- CreateIndex
CREATE INDEX "idx_project_tags_tag" ON "project_tags"("tag_id");

-- AddForeignKey
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "refresh_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_members" ADD CONSTRAINT "project_members_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_members" ADD CONSTRAINT "project_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "layers" ADD CONSTRAINT "layers_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "canvas_states" ADD CONSTRAINT "canvas_states_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "canvas_states" ADD CONSTRAINT "canvas_states_layer_id_fkey" FOREIGN KEY ("layer_id") REFERENCES "layers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ai_generations" ADD CONSTRAINT "ai_generations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ai_generations" ADD CONSTRAINT "ai_generations_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invites" ADD CONSTRAINT "invites_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invites" ADD CONSTRAINT "invites_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_tags" ADD CONSTRAINT "project_tags_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_tags" ADD CONSTRAINT "project_tags_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "tags"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddCheckConstraint
-- Not expressible in Prisma schema DSL; added manually to match the DB design doc's DDL.
ALTER TABLE "projects" ADD CONSTRAINT "projects_width_check" CHECK ("width" BETWEEN 16 AND 256);
ALTER TABLE "projects" ADD CONSTRAINT "projects_height_check" CHECK ("height" BETWEEN 16 AND 256);
ALTER TABLE "layers" ADD CONSTRAINT "layers_opacity_check" CHECK ("opacity" BETWEEN 0 AND 100);
