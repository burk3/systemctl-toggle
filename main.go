package main

import (
	"os"
	"os/exec"
	"strings"

	"github.com/spf13/cobra"
)

func listUnits(user bool) []string {
	args := []string{"list-unit-files", "--type=service", "--no-legend", "--no-pager"}
	if user {
		args = append([]string{"--user"}, args...)
	}
	out, err := exec.Command("systemctl", args...).Output()
	if err != nil {
		return nil
	}
	var units []string
	for _, line := range strings.Split(strings.TrimSpace(string(out)), "\n") {
		if fields := strings.Fields(line); len(fields) > 0 {
			units = append(units, fields[0])
		}
	}
	return units
}

func main() {
	var user bool

	root := &cobra.Command{
		Use:   "systemctl-toggle <unit>",
		Short: "Toggle a systemd service unit on or off",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			unit := args[0]

			checkArgs := []string{"is-active", "--quiet"}
			if user {
				checkArgs = append([]string{"--user"}, checkArgs...)
			}
			checkArgs = append(checkArgs, unit)

			active := exec.Command("systemctl", checkArgs...).Run() == nil

			action := "start"
			if active {
				action = "stop"
			}

			runArgs := []string{}
			if user {
				runArgs = append(runArgs, "--user")
			}
			runArgs = append(runArgs, action, unit)

			c := exec.Command("systemctl", runArgs...)
			c.Stdout = os.Stdout
			c.Stderr = os.Stderr
			return c.Run()
		},
		ValidArgsFunction: func(cmd *cobra.Command, args []string, toComplete string) ([]string, cobra.ShellCompDirective) {
			if len(args) != 0 {
				return nil, cobra.ShellCompDirectiveNoFileComp
			}
			return listUnits(user), cobra.ShellCompDirectiveNoFileComp
		},
	}

	root.Flags().BoolVar(&user, "user", false, "Operate on user services")

	if err := root.Execute(); err != nil {
		os.Exit(1)
	}
}
