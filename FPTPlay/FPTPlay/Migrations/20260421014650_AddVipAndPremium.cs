using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FPTPlay.Migrations
{
    /// <inheritdoc />
    public partial class AddVipAndPremium : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsVip",
                table: "Users",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsPremium",
                table: "Movies",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsVip",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "IsPremium",
                table: "Movies");
        }
    }
}
