/*
  Warnings:

  - You are about to drop the `CoffeeRecipe` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "CoffeeRecipe" DROP CONSTRAINT "CoffeeRecipe_authorId_fkey";

-- DropTable
DROP TABLE "CoffeeRecipe";
